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


#define VERSION (@"0.8.1")

#define KEY_VERSION     (@"-v")


#define KEY_IDENTITY    (@"-i")
#define KEY_CONTROL     (@"-c")
#define KEY_OUTPUT      (@"-o")
#define KEY_KILL        (@"-kill")
#define KEY_NOTIFID     (@"--nid")
#define KEY_EXECUTE     (@"-e")

#define CODE_START  (@"start")
#define CODE_STOP   (@"stop")


#define DEBUG_BOOTFROMAPP   (@"DEBUG_BOOTFROMAPP")

#define PRIVATEKEY_SERVERS     (@"servers")

#define DEFAULT_OUTPUT_PATH (@"DEFAULT_OUTPUT_PATH")


#define MESSAGE_LAUNCHED    (@"nnotifd launched")
#define MESSAGE_EXECUTE_IGNOREDONLAUNCH (@"nnotifd ignored executes on laundh")
#define MESSAGE_EXECUTE_IGNOREDBEFORESTART  (@"nnotifd ignored executes before server start")
#define MESSAGE_EXECUTE_FAILED  (@"nnotifd failed to execute:")
#define MESSAGE_EXECUTED    (@"nnotifd executes was executed:")
#define MESSAGE_MESSAGEID_RECEIVED  (@"nnotifd received notification id:")
#define MESSAGE_INPUTRECEIVED (@"nnotifd input received")
#define MESSAGE_UPDATED     (@"nnotifd updated")
#define MESSAGE_SERVING     (@"nnotifd start serving")
#define MESSAGE_STOPSERVING (@"nnotifd stop serving")
#define MESSAGE_TEARDOWN    (@"nnotifd teardown")

//execute
#define NN_HEADER   (@"nn@")
#define NN_JSON_PARTITION   (@"nn:")
#define NN_SPACE    (@" ")
#define NN_DEFAULT_ROUTE    (@"NN_DEFAULT_ROUTE")

#define DEFINE_PIPE (@"|")

#define FAILBY_NOEXEC   (@"there is no executable command before '|'")


@interface AppDelegate : NSObject <NSApplicationDelegate>

- (id) initWithArgs:(NSDictionary * )dict;

- (bool) isRunning;

- (NSString * )identity;

- (void) writeLogLine:(NSString * )message;
- (NSArray * )bufferedOutput;
- (NSString * )outputPath;

@end
