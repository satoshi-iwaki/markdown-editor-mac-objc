//
//  ContentsManager.h
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextConverter.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName ContentsManagerDidChangeContentNotification;

@interface ContentsManager : NSObject

@property (copy, readonly) NSString *html;
@property (readonly) NSURL *url;
@property (copy, readonly) NSArray<NSString *> *converters;
@property NSUInteger selectedConverterIndex;

+ (instancetype)sharedInstance;

- (void)setContentWithString:(NSString *)string;

- (TextConverter *)selectedConverter;

@end

NS_ASSUME_NONNULL_END
