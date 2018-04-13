//
//  PreferenceManager.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/04/11.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import "PreferenceManager.h"

static NSString *AutoReloadEnabledKey = @"AutoReloadEnabled";

@implementation PreferenceManager

+ (PreferenceManager *)sharedManager {
    static PreferenceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)autoReloadEnabled {
    @synchronized (self) {
        return [NSUserDefaults.standardUserDefaults boolForKey:AutoReloadEnabledKey];
    }
}

- (void)setAutoReloadEnabled:(BOOL)value {
    @synchronized (self) {
        [NSUserDefaults.standardUserDefaults setBool:value forKey:AutoReloadEnabledKey];
    }
}

- (void)resetToDefaults {
    @synchronized (self) {
        [NSUserDefaults resetStandardUserDefaults];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:AutoReloadEnabledKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

@end
