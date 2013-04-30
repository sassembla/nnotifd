//
//  nnotifd.m
//  nnotifd
//
//  Created by sassembla on 2013/04/29.
//  Copyright (c) 2013年 KISSAKI Inc,. All rights reserved.
//

#import "nnotifd.h"
#import "AppDelegate.h"

@implementation nnotifd
int NSApplicationMain(int argc, const char *argv[]) {
    @autoreleasepool {
        
        NSMutableArray * keyAndValueStrArray = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < argc; i++) {
            
            [keyAndValueStrArray addObject:[NSString stringWithUTF8String:argv[i]]];
            
        }
        
        NSMutableDictionary * argsDict = [[NSMutableDictionary alloc]init];
        
        for (int i = 0; i < [keyAndValueStrArray count]; i++) {
            NSString * keyOrValue = keyAndValueStrArray[i];
            if ([keyOrValue hasPrefix:KEY_PERFIX]) {
                NSString * key = keyOrValue;
                
                // get value
                if (i + 1 < [keyAndValueStrArray count]) {
                    NSString * value = keyAndValueStrArray[i + 1];
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
        
        AppDelegate * delegate = [[AppDelegate alloc] initWithArgs:argsDict];
        
        NSApplication * application = [NSApplication sharedApplication];
        [application setDelegate:delegate];

        [NSApp run];
        return 0;
    }
    
}

@end
