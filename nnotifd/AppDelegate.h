//
//  AppDelegate.h
//  nnotifd
//
//  Created by sassembla on 2013/04/29.
//  Copyright (c) 2013年 KISSAKI Inc,. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#define NNOTIFD (@"NNOTIFD")

#define KEY_PERFIX  (@"-")


typedef enum {
    STATUS_STOPPED= 0,
    STATUS_RUNNING
} nnotifd_status;

#define CODE_START  (@"start")
#define CODE_STOP   (@"stop")
#define CODE_RESTART    (@"restart")

#define KEY_IDENTITY    (@"-i")
#define KEY_CONTROL     (@"-c")
#define KEY_OUTPUT      (@"-o")

#define PRIVATEKEY_SERVERS     (@"servers")

#define DEFAULT_OUTPUT_PATH (@"DEFAULT_OUTPUT_PATH")


#define MESSAGE_LAUNCHED    (@"nnotifd launched")




@interface AppDelegate : NSObject <NSApplicationDelegate>

- (id) initWithArgs:(NSDictionary * )dict;

- (bool) isRunning;

- (NSString * )identity;
- (NSString * )output;
- (NSString * )outputPath;

- (void) stop;
@end
