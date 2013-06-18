/**
 *  NSObject+JSON.m
 *  
 *  Created by Greg Pasquariello on 3/5/12.
 *  Copyright (c) 2012 BiggerMind Software. All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *  
 *  Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *  
 *  Neither the name of this project's author nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 *  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 *  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

#import "NSObject+JSON.h"
#import <objc/runtime.h>
#import "NSObject+Properties.h"

@implementation NSManagedObject (JSON)

-(id) createInstanceOfClass:(Class)c {
    NSManagedObject *instance = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(c) inManagedObjectContext:self.managedObjectContext];
    return instance;
}

+(NSMutableArray *) arrayOfObjectsFromJSON:(NSString *)json inManagedObjectContext:(NSManagedObjectContext *) context {
    NSMutableArray *result = nil;
    
    id jsonData = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error:nil];
    
    if ([jsonData isKindOfClass: [NSArray class]]) {
        NSArray *jsonArray = (NSArray *)jsonData;
        
        result = [NSMutableArray arrayWithCapacity: [jsonArray count]];

        for (NSDictionary *data in jsonArray) {
            NSManagedObject *instance = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext: context];
            [instance fromJSONDictionary: data];
            [result addObject: instance];
        }
    }
    
    return result;
}

@end


@implementation NSObject (JSON)

+(NSMutableArray *) arrayOfObjectsFromJSON:(NSString *)json {
    NSMutableArray *result = nil;
    
    id jsonData = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error:nil];
    
    if ([jsonData isKindOfClass: [NSArray class]]) {
        NSArray *jsonArray = (NSArray *)jsonData;
        
        result = [NSMutableArray arrayWithCapacity: [jsonArray count]];
        
        for (NSDictionary *data in jsonArray) {
            id obj = [NSObject createInstanceOfClass: self];
            [obj fromJSONDictionary: data];
            [result addObject: obj];
        }
    }
    
    return result;
}

-(id) initWithJSON:(NSString *) json {
    if (self != nil) {
        [self fromJSON: json];
    }
    return self;
}

-(id) createInstanceOfClass:(Class)c {
    id instance = [[c alloc] init];
    return instance;
}

-(void) fromJSON:(NSString *)json {
    id jsonData = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error:nil];
    if ([jsonData isKindOfClass: [NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)jsonData;
        [self fromJSONDictionary:dict];
    }
}


-(id) fromJSONDictionary:(NSDictionary *)dictionary {    
    NSArray *names = [self propertyNames];
    for (int i=0; i < [names count]; i++) {
        NSString *pname = [names objectAtIndex: i];
        NSString *ptype = [[NSString alloc] initWithUTF8String: [self typeOfPropertyNamed: pname]]; 
        
        NSString *key = [self inputKeyForPropertyNamed: pname];
        if (key == nil) {
            key = pname;
        }
        
        // [__NSCFBoolean objectForKey:]: unrecognized selector sent to instance, pname = Street, ptype = T@"NSString", dictionary = 1, [dictionary class] = __NSCFBoolean
        id value = [dictionary objectForKey: key];
        
        if (value != [NSNull null]) {
            if ([ptype isEqualToString: @"T@\"NSString\""]) {
                [self setValue: [self valueToString: value] forKey: pname];
            } else if ([ptype isEqualToString: @"T@\"NSNumber\""]) {
                [self setValue: [self valueToNumber: value] forKey: pname];
            } else if ([ptype isEqualToString: @"T@\"NSArray\""] 
                       || [ptype isEqualToString: @"T@\"NSMutableArray\""] 
                       || [ptype isEqualToString: @"T@\"NSSet\""] 
                       || [ptype isEqualToString: @"T@\"NSOrderedSet\""]) {
                Class itemClass = [self classForObjectsIn: pname];
                
                NSArray *source = (NSArray *)value;
                NSMutableArray *array = [[NSMutableArray alloc] init];
                
                // [__NSCFBoolean count]: unrecognized selector sent to instance: source = 1, ptype = T@"NSMutableArray", pname = LogoIncluded, dictionary = (NSDictionary *) $1 = 0x0a1a4310 {CampaignDateEnd = "9999-12-31 23:59:59Z"; CampaignDateStart = "0001-01-01 00:00:00Z"; CampaignLink = "/Butik/MyMobileKampagne.aspx?device=appmobile"; ImageLink = "/~/media/Q8/Mobile/Adds/add2x.ashx"; LogoIncluded = 1;}
                for (int i=0; i < [source count]; i++) {
                    id obj = nil;
                    
                    if ([itemClass isSubclassOfClass: [NSString class]]) {
                        obj = [self valueToString: [source objectAtIndex:i]];
                    }
                    else if ([itemClass isSubclassOfClass: [NSNumber class]]) {
                        obj = [self valueToNumber: [source objectAtIndex: i]];
                    }
                    else {
                        NSDictionary *values = [source objectAtIndex: i];
                        
                        obj = [self createInstanceOfClass: itemClass];
                        [obj fromJSONDictionary: values];
                    }
                    
                    [array addObject: obj];
                }
                
                if ([ptype isEqualToString: @"T@\"NSSet\""]) {
                    NSMutableSet *set = [NSMutableSet setWithArray: array];
                    [self setValue: set forKey: pname];
                }
                else if ([ptype isEqualToString: @"T@\"NSOrderedSet\""]) {
                    NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSetWithArray: array];
                    [self setValue: set forKey: pname];
                }
                else {
                    [self setValue: array forKey: pname];
                }
                
            } else if ([ptype isEqualToString: @"Ti"]) {
                [self setValue: [self valueToNumber: value] forKey: pname];
            } else if ([ptype isEqualToString: @"TI"]) {
                [self setValue: [self valueToNumber: value] forKey: pname];
            } else if ([ptype isEqualToString: @"Tl"]) {
                [self setValue: [self valueToNumber: value] forKey: pname];        
            } else if ([ptype isEqualToString: @"TL"]) {
                [self setValue: [self valueToNumber: value] forKey: pname];
            } else if ([ptype isEqualToString: @"Td"]) {
                [self setValue: [self valueToNumber: value] forKey: pname];           
            } else if ([ptype isEqualToString: @"Tf"]) {
                [self setValue: [self valueToNumber: value] forKey: pname];
            } else if ([ptype isEqualToString: @"TB"]) {
                [self setValue: [self valueToNumber: value] forKey: pname];
            } else {
                NSString *className = [self classFromPropertyTypeString: ptype];
                Class class = NSClassFromString(className);
                id object = [self createInstanceOfClass: class];
                [object fromJSONDictionary: value];
                [self setValue:object forKey:pname];
            }
        }
    }
    
    return self;
}


-(NSString *) toJSON {
    NSMutableDictionary *dictionary = [self toJSONDictionary];
    NSData *data = [NSJSONSerialization dataWithJSONObject: dictionary options: 0 error:nil];
    return [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
}

- (NSMutableDictionary *)toJSONDictionary {    
    NSArray *pnames = [self propertyNames];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: [pnames count]];
    
    for (int i=0; i < [pnames count]; i++) {
        NSString *pname = [pnames objectAtIndex: i];
        NSString *ptype = [[NSString alloc] initWithUTF8String: [self typeOfPropertyNamed: pname]]; 
        
        NSString *key = [self outputKeyForPropertyNamed: pname];
        if (key == nil) {
            key = pname;
        }
        //@try
        //{
            if ([ptype isEqualToString: @"T@\"NSString\""]) {
                [dict setValue: [self valueForKey: pname] forKey: key];
            } else if ([ptype isEqualToString: @"T@\"NSNumber\""]) {
                [dict setValue: [self valueForKey: pname] forKey: key];
            } else if ([ptype isEqualToString: @"T@\"NSArray\""] 
                       || [ptype isEqualToString: @"T@\"NSMutableArray\""] 
                       || [ptype isEqualToString: @"T@\"NSSet\""]
                       || [ptype isEqualToString: @"T@\"NSOrderedSet\""]) {
                Class itemClass = [self classForObjectsIn: pname];
                
                NSArray *objectArray = nil;
                
                if ([ptype isEqualToString: @"T@\"NSSet\""] || [ptype isEqualToString: @"T@\"NSOrderedSet\""]) {
                    NSSet *set = [self valueForKey: pname];
                    objectArray = [set allObjects];
                }
                else {
                    objectArray = [self valueForKey: pname];
                }
                
                NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity: [objectArray count]];
                
                
                for(int i=0; i < [objectArray count]; i++) {
                    if ([itemClass isSubclassOfClass:[NSString class]]) {
                        NSString *s = [objectArray objectAtIndex: i];
                        [jsonArray addObject: s];
                    }
                    else if ([itemClass isSubclassOfClass:[NSNumber class]]) {
                        NSNumber *n = [objectArray objectAtIndex: i];
                        [jsonArray addObject: n];
                    }
                    else {
                        id obj = [objectArray objectAtIndex:i];
                        NSDictionary *objDict = [obj toJSONDictionary];
                        [jsonArray addObject: objDict];
                    }
                }
                
                [dict setValue: jsonArray forKey: key];
            } else if ([ptype isEqualToString: @"Ti"]) {
                [dict setValue: [self valueForKey: pname] forKey: key];  
            } else if ([ptype isEqualToString: @"TI"]) {
                [dict setValue: [self valueForKey: pname] forKey: key];
            } else if ([ptype isEqualToString: @"Tl"]) {
                [dict setValue: [self valueForKey: pname] forKey: key];
            } else if ([ptype isEqualToString: @"TL"]) {
                [dict setValue: [self valueForKey: pname] forKey: key];
            } else if ([ptype isEqualToString: @"Td"]) {
                [dict setValue: [self valueForKey: pname] forKey: key];
            } else if ([ptype isEqualToString: @"Tf"]) {
                [dict setValue: [self valueForKey: pname] forKey: key];
            } else if ([ptype isEqualToString: @"TB"]) {
                [dict setValue: [self valueForKey: pname] forKey: key];
            } else {
                id object = [self valueForKey: pname];
                [dict setValue: [object toJSONDictionary] forKey:pname];
            }
        //}
        //@catch (NSException *e)
        //{
            //[NSException raise:@"Did not recognize object type" format:@"input of property name: %@ and property type: %@ is invalid", pname, ptype];
        //}
    }
    
    return dict;
}



- (NSString *) classFromPropertyTypeString:(NSString *)typeString {
    NSRange range;
    range.location = 3;
    range.length = [typeString length] - 4;
    
    NSString *className = [typeString substringWithRange: range];
    
    return className;
}

/**
 Accept a value of any valid JSON type and attempt to convert it to a string
 **/
-(NSString *)valueToString:(id)value {
    NSString *result = nil;
    
    if ([value isKindOfClass: [NSString class]]) {
        result = value;
    }
    else if ([value isKindOfClass: [NSNumber class]]) {
        result = [((NSNumber *)value) stringValue];
    }
    
    return result;
}


/**
 Accept a value of valid JSON type and attempt to convert it to a number
 **/
-(NSNumber *)valueToNumber:(id)value {
    NSNumber *result = nil;
    
    if ([value isKindOfClass: [NSNumber class]]) {
        result = value;
    }
    else if ([value isKindOfClass: [NSString class]]) {
        NSString *svalue = (NSString *)value;
        
        if ([[svalue lowercaseString] isEqualToString: @"false"]) {
            result = [NSNumber numberWithBool: NO];
        }
        else if ([[svalue lowercaseString] isEqualToString: @"true"]) {
            result = [NSNumber numberWithBool: YES];
        }
        else {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            result = [formatter numberFromString: svalue];
        }
    }
    
    return result;
}


- (Class) classForObjectsIn:(NSString *)collectionName {
    return nil;
}

- (NSString *)inputKeyForPropertyNamed:(NSString *)name {
    return name;
}

- (NSString *)outputKeyForPropertyNamed:(NSString *)name {
    return name;
}

@end
