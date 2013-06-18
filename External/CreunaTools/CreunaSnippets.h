//
//  CreunaSnippets.h
//  Drive
//
//  Created by Kåre Harbo Poulsen on 10/15/12.
//  Copyright (c) 2013 Creuna Danmark. All rights reserved.
//

#ifndef Drive_CreunaSnippets_h
#define Drive_CreunaSnippets_h

#define CREUNA_MIN(a, b) a > b ? b : a;

// Returns x clamped to the [min ; max] interval. Does not change x!
#define CREUNA_CLAMP(min,x,max) ((x)<(min)?(min):(x)>(max)?(max):(x))

#define CREUNA_DYNAMIC_CAST(cls, input)                 \
    ({                                                  \
        cls* inst = (cls*)(input);                        \
        [inst isKindOfClass:[cls class]] ? inst : nil;  \
    })

#define NIL_IF_NULL( input ) (input == NULL) ? nil : input

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

#define CREUNA_TIMER_LOG( message )                     \
    ({                                                  \
        static NSDate* initialTime = nil;               \
    if (!initialTime)                                   \
    {                                                   \
        initialTime = [NSDate date];                    \
    }                                                   \
    NSTimeInterval diff = [[NSDate date] timeIntervalSince1970] - initialTime.timeIntervalSince1970; \
    CREUNA_LOG(([NSString stringWithFormat:@"T+%f millis: %@", diff * 1000.0, message])); \
    })


/* 
 determine os versions (http://stackoverflow.com/questions/7848766/how-can-we-programmatically-detect-which-ios-version-is-device-running-on)

 USAGE:

 if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
    // code here
 }
*/
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
