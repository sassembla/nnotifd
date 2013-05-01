//
//  nnotifdTests.h
//  nnotifdTests
//
//  Created by sassembla on 2013/04/29.
//  Copyright (c) 2013年 KISSAKI Inc,. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "AppDelegate.h"


#define TEST_NOTIFICATION_NAME  (@"TEST_NOTIFICATION_NAME_2013/04/29 21:09:03")
#define TEST_DISTNOTIF_MESSAGE  (@"TEST_DISTNOTIF_MESSAGE_2013/04/30 14:02:35")
#define TEST_OUTPUT (@"/Users/sassembla/Desktop/test.txt")

#define NNOTIF  (@"./nnotif")//pwd = project-folder path.
#define NNOTIFD (@"./app/nnotifd")

@interface TestDistNotificationSender : NSObject @end
@implementation TestDistNotificationSender

- (void) sendNotification:(NSString * )identity withMessage:(NSString * )message withKey:(NSString * )key {
    
    NSArray * clArray = @[@"-t", identity, @"-k", key, @"-i", message];
    
    NSTask * task1 = [[NSTask alloc] init];
    [task1 setLaunchPath:NNOTIF];
    [task1 setArguments:clArray];
    [task1 launch];
    [task1 waitUntilExit];
    
    //待つ
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}
@end


@interface TestRunNnotifd : NSObject @end
@implementation TestRunNnotifd

- (void) run:(NSArray * )input {
    
    NSTask * task1 = [[NSTask alloc] init];
    [task1 setLaunchPath:NNOTIFD];
    [task1 setArguments:input];
    [task1 launch];
    
    //待つ
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}
@end




@interface nnotifdTests : SenTestCase {
    AppDelegate * nnotifiedAppDel;
}

@end


@implementation nnotifdTests



- (void)tearDown {
    //outファイルが存在すれば消す
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:TEST_OUTPUT error:NULL];
    
    //プロセスが生き残っていればKILLする
    NSArray * execArray = @[NN_HEADER, KEY_KILL];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
//    //生き残りがあればエラーで落とす、、つもりだったんだけど、テストのインスタンスの破棄はARCなんで、ここでも死なない。
//    NSTask * task = [[NSTask alloc]init];
//    NSPipe * outPipe = [[NSPipe alloc]init];
//    NSPipe * outPipe2 = [[NSPipe alloc]init];
//    NSPipe * outPipe3 = [[NSPipe alloc]init];
//    
//    //ps aux | grep '[n]notifd' | awk '{print $2}'
//    
//    [task setStandardOutput:outPipe];
//    [task setLaunchPath:@"/bin/ps"];
//    [task setArguments:@[@"aux"]];
//
//    
//    NSTask * task2 = [[NSTask alloc]init];
//    [task2 setStandardInput:outPipe];
//    [task2 setStandardOutput:outPipe2];
//    [task2 setLaunchPath:@"/usr/bin/grep"];
//    [task2 setArguments:@[@"'[n]notifd'"]];
//    
//    NSTask * task3 = [[NSTask alloc]init];
//    [task3 setStandardInput:outPipe2];
//    [task3 setStandardOutput:outPipe3];
//    [task3 setLaunchPath:@"/usr/bin/awk"];
//    [task3 setArguments:@[@"'{print $2}'"]];
//
//    [task launch];
////    [task2 launch];
////    [task3 launch];
//    
//    NSFileHandle * handle = [outPipe fileHandleForReading];
//    NSData * data = [handle  readDataToEndOfFile];
//    NSString * str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSLog(@"str %@", str);
    
//    [task waitUntilExit];
//    [task2 waitUntilExit];
//    [task3 waitUntilExit];
    
    [super tearDown];
}


/**
 起動
 オプション一覧
 -c start|restart|stop
 -i set identity
 -o file for output
 
 起動、オプション渡しはコマンドラインからのみ可能、オプションの設定はnnotifからのみ可能。
 */



/**
 テスト用 起動をアプリとして行う
 */
- (void) testLaunchAsAppWithoutOpt {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME, DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    bool running = [nnotifiedAppDel isRunning];
    STAssertFalse(running, @"is running");
    
}


/**
 起動オプションあり
 */
- (void) testLaunchAsAppWithStartOpt {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL: @"start",
                            DEBUG_BOOTFROMAPP:@""};
    
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
   
    bool running = [nnotifiedAppDel isRunning];
    STAssertTrue(running, @"not running");
}


/**
 出力のオプションあり
 */
- (void) testLaunchAsAppWithSomeOpt {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];

    bool running = [nnotifiedAppDel isRunning];
    STAssertFalse(running, @"is running");
    
    NSString * name = [nnotifiedAppDel identity];
    STAssertTrue([name isEqualToString:TEST_NOTIFICATION_NAME], @"not match, %@", name);

    NSString * outPath = [nnotifiedAppDel outputPath];
    STAssertTrue([outPath  isEqualToString:TEST_OUTPUT], @"not match, %@",  outPath);
}

/**
 出力のオプションがあり、実際に出力が出ている
 */
- (void) testCheckLaunchOutput {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //processがlaunchされたことはメッセージから検知できるはず
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    STAssertTrue([readFromOutputArray[0] isEqualToString:MESSAGE_LAUNCHED], @"not match, %@", readFromOutputArray[0]);
}


/**
 出力オプションあり、起動
 */
- (void) testCheckLaunchOutputAndStart {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL: @"start",
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_LAUNCHEDとMESSAGE_SERVINGがあるはず
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    
    STAssertTrue([array containsObject:MESSAGE_LAUNCHED], @"MESSAGE_LAUNCHED not be contained");
    STAssertTrue([array containsObject:MESSAGE_SERVING], @"MESSAGE_SERVING not be contained");

}

/**
 startを送る前はstopな筈
 */
- (void) testLaunchAsAppWithoutStart {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    NSArray * array = [nnotifiedAppDel bufferedOutput];
    STAssertTrue([array containsObject:MESSAGE_LAUNCHED], @"not contains");
    STAssertFalse([array containsObject:MESSAGE_SERVING], @"contains");
    
    //起動していないはず
    bool running = [nnotifiedAppDel isRunning];
    STAssertFalse(running, @"running");
}

/**
 nnotifからのstartを受け取る
 */
- (void) testLaunchAsAppWithoutStartThenReceiveStart {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //送付
    NSArray * execArray = @[NN_HEADER, KEY_CONTROL, CODE_START, KEY_NOTIFID, @"2013/05/01_11:29:39"];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //起動しているはず
    bool running = [nnotifiedAppDel isRunning];
    STAssertTrue(running, @"not running");
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_LAUNCHEDとMESSAGE_SERVINGがあるはず
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    
    STAssertTrue([array containsObject:MESSAGE_LAUNCHED], @"MESSAGE_LAUNCHED not be contained");
    STAssertTrue([array containsObject:MESSAGE_SERVING], @"MESSAGE_SERVING not be contained");
}



/**
 AppでのKILLチェック
 */
- (void) testLaunchAsAppWithoutStartThenReceiveKill {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //kill送付
    NSArray * execArray = @[NN_HEADER, KEY_KILL];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //teardown済みのログが出ている
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    STAssertTrue([readFromOutputArray containsObject:MESSAGE_TEARDOWN], @"not contains, %@", readFromOutputArray);
}



/**
 start後にstopNotifで停める
 */
- (void) testStopAsAppAfterStart {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL:CODE_START,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //stop送付
    NSArray * execArray = @[NN_HEADER, KEY_CONTROL, CODE_STOP];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];

    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    //停止した情報のログが残っている筈
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    STAssertTrue([readFromOutputArray containsObject:MESSAGE_STOPSERVING], @"not contains, %@", readFromOutputArray);
}

/**
 notifでのstart後に停める
 */
- (void) testStopAsAppAfterNotifStart {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    
    {//start送付
        NSArray * execArray = @[NN_HEADER, KEY_CONTROL, CODE_START];
        NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
        TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
        [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    }
    
    {//stop送付
        NSArray * execArray = @[NN_HEADER, KEY_CONTROL, CODE_STOP];
        NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
        TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
        [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    }
    
    //停止した情報のログが残っている筈
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    STAssertTrue([readFromOutputArray containsObject:MESSAGE_STOPSERVING], @"not contains, %@", readFromOutputArray);    
}

/**
 start無しに停める
 */
- (void) testStopAsAppWithoutStart {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //stop送付
    NSArray * execArray = @[NN_HEADER, KEY_CONTROL, CODE_STOP];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];

    
    //停止した情報のログは残っていない筈
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    STAssertFalse([readFromOutputArray containsObject:MESSAGE_STOPSERVING], @"contains, %@", readFromOutputArray);

}



// <- App / CommandLine -> /////////////////////////////


/**
 コマンドラインからの起動、startオプションなし
 */
- (void) testLaunchWithoutStart{
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_OUTPUT, TEST_OUTPUT]
     ];
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_LAUNCHEDがあるはず
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    
    STAssertTrue([array containsObject:MESSAGE_LAUNCHED], @"MESSAGE_LAUNCHED is not contained");
}

/**
 コマンドラインからの起動、startオプションあり
 */
- (void) testLaunchWithStart {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_CONTROL,CODE_START,
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_OUTPUT, TEST_OUTPUT]
     ];
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_SERVINGがあるはず
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    
    STAssertTrue([array containsObject:MESSAGE_SERVING], @"MESSAGE_SERVING is not contained");
}

/**
 notificationでのインスタンスKILL
 */
- (void) testKill {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_OUTPUT, TEST_OUTPUT]
     ];
    
    
    //kill送付
    NSArray * execArray = @[NN_HEADER, KEY_KILL];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_TEARDOWNがあるはず
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    STAssertTrue([array containsObject:MESSAGE_TEARDOWN], @"MESSAGE_TEARDOWN is not contained");
}

- (void) testStopAfterStart {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_CONTROL,CODE_START,
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_OUTPUT, TEST_OUTPUT]
     ];
    
    
    //stop送付
    NSArray * execArray = @[NN_HEADER, KEY_CONTROL, CODE_STOP];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_STOPSERVINGがあるはず
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    STAssertTrue([array containsObject:MESSAGE_STOPSERVING], @"MESSAGE_STOPSERVING is not contained");
}

- (void) testStop {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_OUTPUT, TEST_OUTPUT]
     ];
    
    //stop送付
    NSArray * execArray = @[NN_HEADER, KEY_CONTROL, CODE_STOP];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //もともと停止しているので、MESSAGE_STOPSERVINGは無い。
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    STAssertFalse([array containsObject:MESSAGE_STOPSERVING], @"MESSAGE_STOPSERVING is contained");
}




@end
