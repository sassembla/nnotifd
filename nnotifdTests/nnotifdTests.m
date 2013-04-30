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

@interface TestDistNotificationSender : NSObject @end
@implementation TestDistNotificationSender

- (void) sendNotification:(NSString * )identity withMessage:(NSString * )message withKey:(NSString * )key {
    
    NSArray * clArray = @[@"-t", identity, @"-k", key, @"-i", message];
    
    NSTask * task1 = [[NSTask alloc] init];
    [task1 setLaunchPath:NNOTIF];
    [task1 setArguments:clArray];
    [task1 launch];
    [task1 waitUntilExit];
}
@end


@interface nnotifdTests : SenTestCase {
    AppDelegate * nnotifiedAppDel;
}

@end


@implementation nnotifdTests


- (void)tearDown
{
    //outファイルが存在すれば消す
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:TEST_OUTPUT error:NULL];
    
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
 テスト用として、起動をアプリとして行う。状態確認のため。
 */
- (void) testLaunchAsAppWithoutOpt {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    bool running = [nnotifiedAppDel isRunning];
    STAssertFalse(running, @"is running");
}


/**
 起動オプションあり
 */
- (void) testLaunchAsAppWithStartOpt {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME, KEY_CONTROL: @"start"};
    
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
   
    bool running = [nnotifiedAppDel isRunning];
    STAssertTrue(running, @"not running");
}


/**
 出力のオプションあり
 */
- (void) testLaunchAsAppWithSomeOpt {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT};
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
                            KEY_OUTPUT:TEST_OUTPUT};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //processがlaunchされたことはメッセージから検知できるはず
    NSString * readFromOutput = [nnotifiedAppDel output];
    STAssertTrue([readFromOutput isEqualToString:MESSAGE_LAUNCHED], @"not match, %@", readFromOutput);
}

/**
 nnotifからのstartを受け取る
 */
- (void) testLaunchAsAppWithoutStartThenReceiveStart {
    NSDictionary * dict = @{KEY_IDENTITY:TEST_NOTIFICATION_NAME,
                            KEY_OUTPUT:TEST_OUTPUT};
    nnotifiedAppDel = [[AppDelegate alloc]initWithArgs:dict];
    
    //送付
    //スペース区切りでコマンドを送る。かな？　specifierはSublimeSocketの方式をまねるといい感じ。nn@で始まっている文字列だった場合、execとして扱おう。
    NSArray * execArray = @[NN_HEADER, KEY_CONTROL, CODE_START];
    NSString * exec = [execArray componentsJoinedByString:NN_SPACE];
    TestDistNotificationSender * sender = [[TestDistNotificationSender alloc] init];
    [sender sendNotification:TEST_NOTIFICATION_NAME withMessage:exec withKey:NN_DEFAULT_ROUTE];
    
    //起動しているはず
    bool running = [nnotifiedAppDel isRunning];
    STAssertTrue(running, @"not running");
}


/**
 コマンドラインからの起動、startオプションあり
 */
- (void) testLaunchWithStart {
    STFail(@"Unit tests are not implemented yet in nnotifdTests");
}


/**
 start以外のオプションが指定された場合
 */
- (void) testLaunchWithIdentityAndOther {
    STFail(@"Unit tests are not implemented yet in nnotifdTests");
}


/**
 Launch時未起動状態
 */
- (void) testLaunchWithoutStart{
    STFail(@"Unit tests are not implemented yet in nnotifdTests");
}



/**
 Launch時未起動状態からの起動
 */
- (void) testStart {
    
}

- (void) testRestart {
//    restart　入力はnnotif経由
    STFail(@"Unit tests are not implemented yet in nnotifdTests");
}


- (void) testStop {
//    stop 入力はnnotif経由
    STFail(@"Unit tests are not implemented yet in nnotifdTests");
}




@end
