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
#define TEST_OUTPUT (@"/Users/sassembla/Desktop/nnotifd_test.log")


#define TEST_EXECUTABLE_ARRAY0  (@[@"/bin/pwd"])
#define TEST_EXECUTABLE_ARRAY1  (@[@"/bin/pwd",@"|",@"/bin/cat", @"/Users/sassembla/Library/Application Support/Sublime Text 2/Packages/SublimeSocket/FilterSettingSamples/TypeScriptFilter.txt"])

#define TEST_EXECUTABLE_ARRAY2  (@[@"/bin/pwd",@"|",@"/bin/cat", @"/Users/sassembla/Library/Application Support/Sublime Text 2/Packages/SublimeSocket/FilterSettingSamples/TypeScriptFilter.txt", @"|", @"/usr/bin/grep", @"-e", @"runShell"])

#define TEST_EXECUTABLE_ARRAY3  (@[@"/usr/bin/tail", @"-f", @"/Users/sassembla/Library/Developer/Xcode/DerivedData/TimeWriter-gidguisngdpeilgbgumjksyigaai/Build/Products/Debug/TimeWriter.app/Contents/MacOS/test.txt"])

#define TEST_EXECUTABLE_ARRAY4  (@[@"/usr/bin/tail", @"-f", @"/Users/sassembla/Library/Developer/Xcode/DerivedData/TimeWriter-gidguisngdpeilgbgumjksyigaai/Build/Products/Debug/TimeWriter.app/Contents/MacOS/test.txt", @"|", @"/usr/bin/grep", @"-e", @"0"])


#define TEST_UNEXECUTABLE_ARRAY0    (@[@"unexecutable"])
#define TEST_UNEXECUTABLE_ARRAY1    (@[@"|"])
#define TEST_UNEXECUTABLE_ARRAY2    (@[@"/bin/pwd",@"|",@"|"])



#define NNOTIF  (@"./nnotif")//pwd = project-folder path.
#define NNOTIFD (@"/Users/sassembla/Library/Developer/Xcode/DerivedData/nnotifd-ahjyuqfrcnbezcaagbkmwszlhqlj/Build/Products/Debug/nnotifd.app/Contents/MacOS/nnotifd")

#define TEST_NNOTIF_OUTPUT  (@"/Users/sassembla/Desktop/nnotif_test.txt")

@interface TestDistNotificationSender : NSObject @end
@implementation TestDistNotificationSender

- (void) sendNotification:(NSString * )identity withMessage:(NSString * )message withKey:(NSString * )key {
    
    NSArray * clArray = @[@"-t", identity, @"-k", key, @"-v", @"-o", TEST_NNOTIF_OUTPUT, @"-i", message];
    
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
    
    [super tearDown];
}


- (NSString * ) jonizedString:(NSArray * )jsonSourceArray {
    
    //add before-" and after-"
    NSMutableArray * addHeadAndTailQuote = [[NSMutableArray alloc]init];
    for (NSString * item in jsonSourceArray) {
        [addHeadAndTailQuote addObject:[NSString stringWithFormat:@"\"%@\"", item]];
    }
    
    //concat with ,
    NSString * concatted = [addHeadAndTailQuote componentsJoinedByString:@","];
    return [[NSString alloc] initWithFormat:@"%@[%@]", NN_JSON_PARTITION, concatted];
}

/**
 version表示
 */
- (void) testVersion {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME, DEBUG_BOOTFROMAPP:@"", KEY_VERSION:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
}

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


/**
 Launch時のExecute(怒られる、なにもおこらない)
 */
- (void) testExecuteAsAppOnLaunch {
    //起動
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL:CODE_START,
                            KEY_OUTPUT:TEST_OUTPUT,
                            KEY_EXECUTE:@"",
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //MESSAGE_EXECUTE_IGNOREDONLAUNCHが残っている
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    STAssertTrue([readFromOutputArray containsObject:MESSAGE_EXECUTE_IGNOREDONLAUNCH], @"not contains, %@", readFromOutputArray);
}


/**
 Launch後、Startする前のExecute(怒られる、なにもおこらない)
 */
- (void) testExecuteAsAppWithoutStart {
    //起動
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //execute送付
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE, @"something"];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //MESSAGE_EXECUTE_IGNOREDBEFORESTARTが残っている
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    STAssertTrue([readFromOutputArray containsObject:MESSAGE_EXECUTE_IGNOREDBEFORESTART], @"not contains, %@", readFromOutputArray);
}


/**
 Start後のExecute
 */
- (void) testExecuteAsApp_NoPipe {
    //起動
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL:CODE_START,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    
    NSArray * execsArray = TEST_EXECUTABLE_ARRAY0;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //MESSAGE_EXECUTE_LAUNCHEDが残っている
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    NSString * command = [TEST_EXECUTABLE_ARRAY0 componentsJoinedByString:NN_SPACE];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_LAUNCHED, command];
    STAssertTrue([readFromOutputArray containsObject:expected], @"not contains, %@", readFromOutputArray);
}

- (void) testExecuteAsApp_1Piped {
    //起動
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL:CODE_START,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    
    NSArray * execsArray = TEST_EXECUTABLE_ARRAY1;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //MESSAGE_EXECUTE_LAUNCHEDが残っている
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    NSString * command = [TEST_EXECUTABLE_ARRAY1 componentsJoinedByString:NN_SPACE];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_LAUNCHED, command];
    STAssertTrue([readFromOutputArray containsObject:expected], @"not contains, %@", readFromOutputArray);
}


- (void) testExecuteAsApp_3Piped {
    //起動
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL:CODE_START,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    
    NSArray * execsArray = TEST_EXECUTABLE_ARRAY2;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //MESSAGE_EXECUTE_LAUNCHEDが残っている
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    NSString * command = [TEST_EXECUTABLE_ARRAY2 componentsJoinedByString:NN_SPACE];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_LAUNCHED, command];
    STAssertTrue([readFromOutputArray containsObject:expected], @"not contains, %@", readFromOutputArray);
}

/**
 存在しないコマンドの実行によるエラー
 */
- (void) testNotExistCommandAsApp {
    //起動
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL:CODE_START,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    
    NSArray * execsArray = TEST_UNEXECUTABLE_ARRAY0;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //MESSAGE_EXECUTE_FAILEDが残っている
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_FAILED, @"unexecutable because of:launch path not accessible"];
    STAssertTrue([readFromOutputArray containsObject:expected], @"not contains, %@", readFromOutputArray);
}

/**
 構文エラーによるエラー
 */
- (void) testUnparseableCommandAsApp {
    //起動
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_CONTROL:CODE_START,
                            KEY_OUTPUT:TEST_OUTPUT,
                            DEBUG_BOOTFROMAPP:@""};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    
    NSArray * execsArray = TEST_UNEXECUTABLE_ARRAY1;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //MESSAGE_EXECUTE_FAILEDが残っている
    NSArray * readFromOutputArray = [nnotifiedAppDel bufferedOutput];
    NSString * expected = [NSString stringWithFormat:@"%@%@%@", MESSAGE_EXECUTE_FAILED, @"| because of:", FAILBY_NOEXEC];
    STAssertTrue([readFromOutputArray containsObject:expected], @"not contains, %@", readFromOutputArray);
}



// <- App / CommandLine -> /////////////////////////////


/**
 コマンドラインからの起動、startオプションなし
 */
- (void) testLaunchWithoutStart{
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
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
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
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
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
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
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
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
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
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


/**
 Launch時のExecute(怒られる、なにもおこらない)
 */
- (void) testExecuteOnLaunch {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_CONTROL,CODE_START,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_EXECUTE,@"",
     KEY_VERSION]
     ];
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_EXECUTE_IGNOREDONLAUNCHが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    STAssertTrue([array containsObject:MESSAGE_EXECUTE_IGNOREDONLAUNCH], @"not contains, %@", array);
}


/**
 Launch後、Startする前のExecute(怒られる、なにもおこらない)
 */
- (void) testExecuteWithoutStart {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
     ];
    
    //execute送付
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE, @"something"];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    

    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_EXECUTE_IGNOREDBEFORESTARTが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    STAssertTrue([array containsObject:MESSAGE_EXECUTE_IGNOREDBEFORESTART], @"not contains, %@", array);
}


/**
 Start後のExecute
 */
- (void) testExecute_NoPipe {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_CONTROL,CODE_START,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
     ];
    
    NSArray * execsArray = TEST_EXECUTABLE_ARRAY0;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_EXECUTE_LAUNCHEDが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    NSString * command = [TEST_EXECUTABLE_ARRAY0 componentsJoinedByString:NN_SPACE];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_LAUNCHED, command];
    STAssertTrue([array containsObject:expected], @"not contains, %@", array);
}

- (void) testExecute_1Piped {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_CONTROL,CODE_START,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
     ];
    
    NSArray * execsArray = TEST_EXECUTABLE_ARRAY1;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_EXECUTE_LAUNCHEDが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    NSString * command = [TEST_EXECUTABLE_ARRAY1 componentsJoinedByString:NN_SPACE];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_LAUNCHED, command];
    STAssertTrue([array containsObject:expected], @"not contains, %@", array);
}


- (void) testExecute_3Piped {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_CONTROL,CODE_START,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
     ];
    
    NSArray * execsArray = TEST_EXECUTABLE_ARRAY2;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    //MESSAGE_EXECUTE_LAUNCHEDが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    NSString * command = [TEST_EXECUTABLE_ARRAY2 componentsJoinedByString:NN_SPACE];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_LAUNCHED, command];
    STAssertTrue([array containsObject:expected], @"not contains, %@", array);
}

/**
 ストリーム閉じない系のコマンドを使った場合の挙動
 */
- (void) testExecute_Continuous {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_CONTROL,CODE_START,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
     ];
    
    NSArray * execsArray = TEST_EXECUTABLE_ARRAY3;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_EXECUTE_LAUNCHEDが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    NSString * command = [TEST_EXECUTABLE_ARRAY3 componentsJoinedByString:NN_SPACE];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_LAUNCHED, command];
    STAssertTrue([array containsObject:expected], @"not contains, %@", array);//ここで待つと、標準出力にtailの結果がでるので、まあ動いてるんだと思う。
}

/**
 パイプ付きで、tail的な継続出力の動作を確認、OK。
 ExecutedはLaunch時にでるので、launchedのほうがいい。
 */
- (void) testExecute_Continuous_Piped {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_CONTROL,CODE_START,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
     ];
    
    NSArray * execsArray = TEST_EXECUTABLE_ARRAY4;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_EXECUTE_LAUNCHEDが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    NSString * command = [TEST_EXECUTABLE_ARRAY4 componentsJoinedByString:NN_SPACE];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_LAUNCHED, command];
    STAssertTrue([array containsObject:expected], @"not contains, %@", array);
}



/**
 存在しないコマンドの実行によるエラー
 */
- (void) testNotExistCommand {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_CONTROL,CODE_START,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
     ];
    
    NSArray * execsArray = TEST_UNEXECUTABLE_ARRAY0;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_EXECUTE_FAILEDが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    NSString * expected = [NSString stringWithFormat:@"%@%@", MESSAGE_EXECUTE_FAILED, @"unexecutable because of:launch path not accessible"];
    STAssertTrue([array containsObject:expected], @"not contains, %@", array);
}

/**
 構文エラーによるエラー
 */
- (void) testUnparseableCommand {
    TestRunNnotifd * nnotifd = [[TestRunNnotifd alloc]init];
    [nnotifd run:@[
     KEY_IDENTITY,TEST_NOTIFICATION_NAME,
     KEY_CONTROL,CODE_START,
     KEY_OUTPUT, TEST_OUTPUT,
     KEY_VERSION]
     ];
    
    NSArray * execsArray = TEST_UNEXECUTABLE_ARRAY1;
    
    //notifでexecuteを送り込む
    NSArray * execArray = @[NN_HEADER, KEY_EXECUTE,[self jonizedString:execsArray]];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //起動している筈なので、ファイルが書き出されている筈
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:TEST_OUTPUT];
    STAssertNotNil(handle, @"handle is nil");
    NSData * data = [handle readDataToEndOfFile];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //MESSAGE_EXECUTE_FAILEDが残っている
    NSArray * array = [string componentsSeparatedByString:@"\n"];
    NSString * expected = [NSString stringWithFormat:@"%@%@%@", MESSAGE_EXECUTE_FAILED, @"| because of:", FAILBY_NOEXEC];
    STAssertTrue([array containsObject:expected], @"not contains, %@", array);
}




@end
