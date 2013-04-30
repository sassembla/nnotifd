//
//  AppDelegate.m
//  nnotifd
//
//  Created by sassembla on 2013/04/29.
//  Copyright (c) 2013年 KISSAKI Inc,. All rights reserved.
//

#import "AppDelegate.h"

#import "KSMessenger.h"


/**
 NSDistributedNotificationを受けるサーバプログラム。
 コマンドラインでの実行のみを行う前提。
 
 httpdとかを参考に、特定のNSDistributedNotoficationをサーブし、コマンドラインを実行する。
 Objective-C serverの分派
 
 NSDistNotifを受け取り、下記を行う
 ・NSDistNotifを発生
 ・CommandLineを実行

 */
@implementation AppDelegate {
    NSMutableDictionary * m_settingDict;

    NSFileHandle * m_writeHandle;
    
    bool m_bootFromApp;
    NSMutableArray * m_bufferedOutput;
}


- (id) initWithArgs:(NSDictionary * )dict {
    if (self = [super init]) {

        m_bootFromApp = false;
        if (dict[DEBUG_BOOTFROMAPP]) {
            m_bootFromApp = true;
        }
        
        if (dict[KEY_IDENTITY]) {
            [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(receiver:) name:dict[KEY_IDENTITY] object:nil];
            
            if (dict[KEY_OUTPUT]) [self setOutput:dict[KEY_OUTPUT]];
            
            //init with stopped
            m_settingDict = [[NSMutableDictionary alloc]initWithDictionary:@{KEY_CONTROL:[[NSNumber alloc]initWithInt:STATUS_STOPPED]}];
            int initializedStatus = STATUS_STOPPED;
            
            if (dict[KEY_CONTROL]) {
                initializedStatus = [self setServe:dict[KEY_CONTROL]];
            }
            
            m_settingDict = [[NSMutableDictionary alloc]initWithDictionary:@{
                             KEY_IDENTITY:dict[KEY_IDENTITY],
                             KEY_CONTROL:[[NSNumber alloc]initWithInt:initializedStatus]}];
            if (dict[KEY_OUTPUT]) [m_settingDict setValue:dict[KEY_OUTPUT] forKey:KEY_OUTPUT];
            
            [self writeLogLine:MESSAGE_LAUNCHED];
        }
    }
    return self;
}

/**
 serve control
 */
- (int) setServe:(NSString * )code {
    
    if ([code isEqualToString:CODE_START]) {
        int status = [m_settingDict[KEY_CONTROL] intValue];
        
        switch (status) {
            case STATUS_RUNNING:{
                NSAssert(false, @"already running, %@", m_settingDict);
                break;
            }
                
            case STATUS_STOPPED:{
                [m_settingDict setValue:[NSNumber numberWithInt:STATUS_RUNNING] forKey:KEY_CONTROL];
                
                [self writeLogLine:MESSAGE_SERVING];

                return STATUS_RUNNING;
            }
                
            default:
                break;
        }
    }
    
    return -1;
}

- (void) receiver:(NSNotification * )notif {
    NSDictionary * dict = [notif userInfo];
    switch ([m_settingDict[KEY_CONTROL] intValue]) {
        case STATUS_STOPPED:{
            //起動サインなどを受け入れる
            if (dict[NN_DEFAULT_ROUTE]) {
                NSString * execs = [[NSString alloc]initWithString:dict[NN_DEFAULT_ROUTE]];
                if ([execs hasPrefix:NN_HEADER]) {
                    NSArray * execArray = [[NSArray alloc]initWithArray:[execs componentsSeparatedByString:NN_SPACE]];

                    if (1 < [execArray count]) {
                        NSArray * subarray = [execArray subarrayWithRange:NSMakeRange(1, [execArray count]-1)];
                        [self readInput:subarray];
                    }
                }
            }
            
            break;
        }
            
        case STATUS_RUNNING:{
            //サーブしてるので、内容に合わせた挙動を行う
            
            //ルーティングを行う
            
            break;
        }
            
        default:
            break;
    }
}

- (void) readInput:(NSArray * )execArray {
    
    NSMutableDictionary * argsDict = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i < [execArray count]; i++) {
        NSString * keyOrValue = execArray[i];
        
        if ([keyOrValue hasPrefix:KEY_PERFIX]) {
            NSString * key = keyOrValue;
            
            // get value
            if (i + 1 < [execArray count]) {
                NSString * value = execArray[i + 1];
                if ([value hasPrefix:KEY_PERFIX]) {
                    [argsDict setValue:@"" forKey:key];
                } else {
                    [argsDict setValue:value forKey:key];
                }
            }
            else {
                NSString * value = @"";
                [argsDict setValue:value forKey:key];
            }
        }
    }
    
    [self writeLogLine:MESSAGE_SETTINGRECEIVED];
    
    if (0 < [argsDict count]) {
        [self update:argsDict];
    }
}

/**
 入力を元に、動作を変更する
 */
- (void) update:(NSDictionary * )argsDict {
    if (argsDict[KEY_OUTPUT]) {
        [self setOutput:argsDict[KEY_OUTPUT]];
    }
    
    if (argsDict[KEY_KILL]) {
        
        [self writeLogLine:MESSAGE_TEARDOWN];
        
        if (m_bootFromApp) {
            
        } else {
            exit(0);
        }
        return;
    }
    
    int latestStatus = [m_settingDict[KEY_CONTROL] intValue];
    
    if (argsDict[KEY_CONTROL]) {
        latestStatus = [self setServe:argsDict[KEY_CONTROL]];
    }
    
    [self writeLogLine:MESSAGE_UPDATED];
}


- (bool) isRunning {
    return [m_settingDict[KEY_CONTROL] intValue] == STATUS_RUNNING;
}

- (NSString * )identity {
    return m_settingDict[KEY_IDENTITY];
}





//output

- (void) writeLogLine:(NSString * )message {
    if (m_bufferedOutput) [m_bufferedOutput addObject:message];
    if (m_writeHandle) {
        NSString * linedMessage = [[NSString alloc] initWithFormat:@"%@\n", message];
        [m_writeHandle writeData:[linedMessage dataUsingEncoding:NSUTF8StringEncoding]];
    }
}


/**
 outputのセット
 */
- (void) setOutput:(NSString * )path {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    //存在しても何も言わないので、先に存在チェック
    NSFileHandle * readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    //ファイルが既に存在しているか
    if (readHandle) {
        NSLog(@"output-target file already exist, we append.");
    }
    
    bool result = [fileManager createFileAtPath:path contents:nil attributes:nil];
    
    NSAssert1(result, @"the output-file:%@ cannot generate or append", path);
    
    if (result) {
        m_bufferedOutput = [[NSMutableArray alloc]init];
        m_writeHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    }
}

/**
 output ファイルの文字列を改行コードごと総て吐き出す
 */
- (NSArray * )bufferedOutput {
    return m_bufferedOutput;
}

- (NSString * )outputPath {
    NSAssert(m_settingDict[KEY_OUTPUT], @"output target path is not set yet.");
    return m_settingDict[KEY_OUTPUT];
}



- (void) stop {
    
}


@end
