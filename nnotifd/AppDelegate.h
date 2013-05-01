//
//  AppDelegate.h
//  nnotifd
//
//  Created by sassembla on 2013/04/29.
//  Copyright (c) 2013年 KISSAKI Inc,. All rights reserved.
//

#import <Cocoa/Cocoa.h>



#define KEY_PERFIX  (@"-")


typedef enum {
    STATUS_STOPPED= 0,
    STATUS_RUNNING
} nnotifd_status;

#define CODE_START  (@"start")
#define CODE_STOP   (@"stop")

#define KEY_IDENTITY    (@"-i")
#define KEY_CONTROL     (@"-c")
#define KEY_OUTPUT      (@"-o")
#define KEY_KILL        (@"-kill")
#define KEY_NOTIFID     (@"--nid")

#define DEBUG_BOOTFROMAPP   (@"DEBUG_BOOTFROMAPP")

#define PRIVATEKEY_SERVERS     (@"servers")

#define DEFAULT_OUTPUT_PATH (@"DEFAULT_OUTPUT_PATH")


#define MESSAGE_LAUNCHED    (@"nnotifd launched")
#define MESSAGE_SETTINGRECEIVED (@"nnotifd setting-input received")
#define MESSAGE_UPDATED     (@"nnotifd updated")
#define MESSAGE_SERVING     (@"nnotifd start serving")
#define MESSAGE_STOPSERVING (@"nnotifd stop serving")
#define MESSAGE_TEARDOWN    (@"nnotifd teardown")

//execute
#define NN_HEADER   (@"nn@")
#define NN_SPACE    (@" ")
#define NN_DEFAULT_ROUTE    (@"NN_DEFAULT_ROUTE")


@interface AppDelegate : NSObject <NSApplicationDelegate>

- (id) initWithArgs:(NSDictionary * )dict;

- (bool) isRunning;

- (NSString * )identity;

- (void) writeLogLine:(NSString * )message;
- (NSArray * )bufferedOutput;
- (NSString * )outputPath;

@end
