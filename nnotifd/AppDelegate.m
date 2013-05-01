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

/**
 起動時処理
 */
- (id) initWithArgs:(NSDictionary * )dict {
    if (self = [super init]) {

        m_bootFromApp = false;
        if (dict[DEBUG_BOOTFROMAPP]) {
            m_bootFromApp = true;
        }
        
        if (dict[KEY_IDENTITY]) {
            m_settingDict = [[NSMutableDictionary alloc]initWithDictionary:@{KEY_IDENTITY:dict[KEY_IDENTITY]}];
            
            [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(receiver:) name:dict[KEY_IDENTITY] object:nil];
            
            if (dict[KEY_OUTPUT]) {
                [self setOutput:dict[KEY_OUTPUT]];
                [m_settingDict setValue:dict[KEY_OUTPUT] forKey:KEY_OUTPUT];
                [self writeLogLine:MESSAGE_LAUNCHED];
            }
            
            //init with stopped
            [m_settingDict setValue:[[NSNumber alloc]initWithInt:STATUS_STOPPED] forKey:KEY_CONTROL];
            
            if (dict[KEY_EXECUTE]) {
                NSLog(@"cannot execute on launch. inputted executes are ignored.");
                [self writeLogLine:MESSAGE_EXECUTE_IGNOREDONLAUNCH];
            }
            
            int initializedStatus = STATUS_STOPPED;
            
            if (dict[KEY_CONTROL]) {
                initializedStatus = [self setServe:dict[KEY_CONTROL]];
            }
            [m_settingDict setValue:[[NSNumber alloc]initWithInt:initializedStatus] forKey:KEY_CONTROL];
            
        }
    }
    return self;
}

/**
 serve control
 */
- (int) setServe:(NSString * )code {
    int status = [m_settingDict[KEY_CONTROL] intValue];
    
    if ([code isEqualToString:CODE_START]) {
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
    
    if ([code isEqualToString:CODE_STOP]) {
        switch (status) {
            case STATUS_RUNNING:{
                [m_settingDict setValue:[NSNumber numberWithInt:STATUS_STOPPED] forKey:KEY_CONTROL];
                
                [self writeLogLine:MESSAGE_STOPSERVING];
                
                return STATUS_STOPPED;
            }
                
            case STATUS_STOPPED:{
                return STATUS_STOPPED;
            }
                
            default:
                break;
        }
    }
    
    return -1;
}

- (void) receiver:(NSNotification * )notif {
    NSDictionary * dict = [notif userInfo];
    if (dict[NN_DEFAULT_ROUTE]) {
        NSString * execs = [[NSString alloc]initWithString:dict[NN_DEFAULT_ROUTE]];
        if ([execs hasPrefix:NN_HEADER]) {
            //まずはJSONとそれ以外に分離する
            NSArray * execAndJSONArray = [[NSArray alloc]initWithArray:[execs componentsSeparatedByString:NN_JSON_PARTITION]];
            
            //残った部分をコマンドラインとして処理する
            NSArray * execArray = [[NSArray alloc]initWithArray:[execAndJSONArray[0] componentsSeparatedByString:NN_SPACE]];
            
            if (1 < [execArray count]) {
                NSArray * subarray = [execArray subarrayWithRange:NSMakeRange(1, [execArray count]-1)];
                if (1 < [execAndJSONArray count]) {
                    [self readInput:subarray withParam:execAndJSONArray[1]];
                } else {
                    [self readInput:subarray withParam:nil];
                }
            }
        }
    }

    
    switch ([m_settingDict[KEY_CONTROL] intValue]) {
        case STATUS_STOPPED:{
            //起動サインなどを受け入れる
            
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

- (void) readInput:(NSArray * )execArray withParam:(NSString * )jsonParam {
    
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
    
    [self writeLogLine:MESSAGE_INPUTRECEIVED];
    
    if (0 < [argsDict count]) {
        [self update:argsDict withParam:jsonParam];
    }
}

/**
 入力を元に、動作を変更する
 */
- (void) update:(NSDictionary * )argsDict withParam:(NSString * )jsonParam {
    if (argsDict[KEY_NOTIFID]) {
        [self writeLogLine:[[NSString alloc]initWithFormat:@"%@%@",MESSAGE_MESSAGEID_RECEIVED, argsDict[KEY_NOTIFID]]];
    }
    
    if (argsDict[KEY_OUTPUT]) {
        [self setOutput:argsDict[KEY_OUTPUT]];
    }
    
    if (argsDict[KEY_KILL]) {
        [[NSDistributedNotificationCenter defaultCenter]removeObserver:self name:m_settingDict[KEY_IDENTITY] object:nil];
        
        [self writeLogLine:MESSAGE_TEARDOWN];
        
        [m_settingDict removeAllObjects];
        
        if (m_bootFromApp) {
            
        } else {
            exit(0);
        }
        return;
    }
    
    int latestStatus = [m_settingDict[KEY_CONTROL] intValue];
    
    if (argsDict[KEY_CONTROL]) {
        latestStatus = [self setServe:argsDict[KEY_CONTROL]];
        [self writeLogLine:MESSAGE_UPDATED];
    }
    
    switch (latestStatus) {
        case STATUS_STOPPED:{
            if (argsDict[KEY_EXECUTE]) {
                [self writeLogLine:MESSAGE_EXECUTE_IGNOREDBEFORESTART];
            }
            break;
        }
        case STATUS_RUNNING:{
            if (argsDict[KEY_EXECUTE]) {
                //read JSON
                [self executeJson:jsonParam];
            }
            break;
        }
            
        default:
            break;
    }
    
    
}


- (bool) isRunning {
    return [m_settingDict[KEY_CONTROL] intValue] == STATUS_RUNNING;
}

- (NSString * )identity {
    return m_settingDict[KEY_IDENTITY];
}

- (void) executeJson:(NSString * )jsonStr {
    NSData * jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //JsonからArray、辞書は受け付けない。pipeを使うのを念頭においているので、ただ連結して実行するだけの形式がベスト。NSTaskか、、
    NSError * err;
    NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];

    if (err) {
        [self writeLogLine:[NSString stringWithFormat:@"%@%@",MESSAGE_EXECUTE_FAILED, jsonStr]];
    } else {
        NSLog(@"jsonArray   %@", jsonArray);
        
                
//        //値がこうで、
//        NSArray * clArray = @[@"-t", identity, @"-k", key, @"-i", message];
//        
//        //実行がこうで、
//        NSTask * task1 = [[NSTask alloc] init];
//        [task1 setLaunchPath:NNOTIF];
//        [task1 setArguments:clArray];
//        
//        //pipeがこうで、
//        [task1 setStandardOutput:currentOut];
//        [task1 setStandardInput:currentIn];
//        
//        //全部揃ってからの実行、と。
//        [task1 launch];
//        [task1 waitUntilExit];
//        
//        pipeの有無とかも考えつつやるのが良いのかなー。
//        ゆーても複数のexecを渡すと、順が指定してあればpipeするよー、くらいしかないんだけど、
//        そもそも直感的に、文字列で渡した物を実行、っつーのが一番ラクなんだけど、""とか邪魔だしなー。
//        ストレートにやると、
//        -eの終わりが判りづらいんだよな、、なによりそれを解析するのがめんどい。あ、無理だ。
//        -e "pwd | echo -p http://~ \"/application support/test\""
//        
//        JSONArrayで、
//        -e ["pwd","|","echo","-p","http://~","\"/application support/test\""] とかか。pipeでdeliして、headとそれ以外、でOK。
//        
//        パスとかが入る場合も考えやすい、かな？　JSONに含まれれば、Validateができる、というアドバンテージがある。
//        OK、JSONにしよう。
        
        [self writeLogLine:[NSString stringWithFormat:@"%@%@",MESSAGE_EXECUTED, jsonArray]];
    }
}



//output

- (void) writeLogLine:(NSString * )message {
    if (m_bufferedOutput) [m_bufferedOutput addObject:message];
    if (m_writeHandle) {
        NSString * linedMessage = [NSString stringWithFormat:@"%@\n", message];
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



@end
