//
//  PreferenceManager.h
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/04/11.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferenceManager : NSObject

@property (class, readonly, strong) PreferenceManager *sharedManager;

@property BOOL autoReloadEnabled;

@end
