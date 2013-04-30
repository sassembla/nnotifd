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
}

- (id) initWithArgs:(NSDictionary * )dict {
    if (self = [super init]) {
        
        if (dict[KEY_IDENTITY]) {
            [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(receiver:) name:dict[KEY_IDENTITY] object:nil];
            
            //init with stopped
            m_settingDict = [[NSMutableDictionary alloc]initWithDictionary:@{KEY_CONTROL:[[NSNumber alloc]initWithInt:STATUS_STOPPED]}];
            int initializedStatus = STATUS_STOPPED;
            
            
            if (dict[KEY_CONTROL]) {
                initializedStatus = [self serve:dict[KEY_CONTROL]];
            }
            
            m_settingDict = [[NSMutableDictionary alloc]initWithDictionary:@{
                             KEY_IDENTITY:dict[KEY_IDENTITY],
                             KEY_CONTROL:[[NSNumber alloc]initWithInt:initializedStatus]}];
            
            if (dict[KEY_OUTPUT]) {
                //このパスへの書き込み権利があるかどうか、とか、ここで判断できると思うけど。
                
                //すでにファイルがあるかどうか
                //書き込み可能かどうか(writecheck)
                
                [m_settingDict setValue:dict[KEY_OUTPUT] forKey:KEY_OUTPUT];
            }
            
        }
    }
    return self;
}

/**
 serve control
 */
- (int) serve:(NSString * )code {
    
    if ([code isEqualToString:CODE_START]) {
        int status = [m_settingDict[KEY_CONTROL] intValue];
        
        switch (status) {
            case STATUS_RUNNING:{
                NSAssert(false, @"already running, %@", m_settingDict);
                break;
            }
                
            case STATUS_STOPPED:{
                [m_settingDict setValue:[NSNumber numberWithInt:STATUS_RUNNING] forKey:KEY_CONTROL];
                
                
                return STATUS_RUNNING;
            }
                
            default:
                break;
        }
    }
    
    return -1;
}

- (void) receiver:(NSNotification * )notif {

    switch ([m_settingDict[KEY_CONTROL] intValue]) {
        case STATUS_STOPPED:{
            
            break;
        }
            
        case STATUS_RUNNING:{
            //サーブしてるので、内容に合わせた挙動を行う
            
            break;
        }
            
        default:
            break;
    }
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //起動
}

- (bool) isRunning {
    return [m_settingDict[KEY_CONTROL] intValue] == STATUS_RUNNING;
}

- (NSString * )identity {
    return m_settingDict[KEY_IDENTITY];
}


//output


/**
 output ファイルの文字列を改行コードごと総て吐き出す
 */
- (NSString * )output {
    NSAssert(m_settingDict[KEY_OUTPUT], @"no-output set yet.");
    
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:m_settingDict[KEY_OUTPUT]];
    NSData * data = [handle readDataToEndOfFile];

    if (data) return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return nil;
}

- (NSString * )outputPath {
    NSAssert(m_settingDict[KEY_OUTPUT], @"output target path is not set yet.");
    return m_settingDict[KEY_OUTPUT];
}



- (void) stop {
    
}


@end
