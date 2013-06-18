//
//  CreunaLockoutLoader.h
//  Drive
//
//  Created by Kåre Harbo Poulsen on 11/12/12.
//  Copyright (c) 2012 Q8 - Kuwait Petroleum (Danmark) A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface CreunaLockoutLoader : NSObject

+ (void) presentInView:(UIView*)view;
+ (void) presentInOverlayWindow;
+ (void) dismiss;

@end