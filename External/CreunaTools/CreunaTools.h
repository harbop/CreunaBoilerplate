//
//  CreunaTools.h
//  Creuna
//
//  Created by Kåre Harbo Poulsen on 10/12/12.
//  Copyright (c) 2013 Creuna Danmark. All rights reserved.
//

#pragma mark LOGGING

#ifndef Creuna_CreunaTools_h
#define Creuna_CreunaTools_h

#ifdef CREUNA_DEBUG_BUILD
#define CREUNA_LOG(...) NSLog(@"CREUNA_LOG: %@", ##__VA_ARGS__);
#endif

#ifdef CREUNA_ADHOC_BUILD
#define CREUNA_LOG(...) NSLog(@"CREUNA_LOG: %@", ##__VA_ARGS__);
#endif

#ifdef CREUNA_APPSTORE_BUILD
#define CREUNA_LOG(...)
#endif

#ifdef CREUNA_RELEASE_BUILD
#define CREUNA_LOG(...)
#endif

#pragma mark DEBUG ALERTS

#ifdef CREUNA_DEBUG_BUILD
#define CREUNA_DEBUG_ALERT(txt) [[[UIAlertView alloc] initWithTitle:@"DEBUG ALERT" message:txt delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
#endif

#ifdef CREUNA_ADHOC_BUILD
#define CREUNA_DEBUG_ALERT(txt) [[[UIAlertView alloc] initWithTitle:@"DEBUG ALERT" message:txt delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
#endif

#ifdef CREUNA_APPSTORE_BUILD
#define CREUNA_DEBUG_ALERT(txt)
#endif

#ifdef CREUNA_RELEASE_BUILD
#define CREUNA_DEBUG_ALERT(txt) 
#endif


#endif
