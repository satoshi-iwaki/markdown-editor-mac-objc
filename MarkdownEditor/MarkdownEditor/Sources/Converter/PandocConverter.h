//
//  PandocConverter.h
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Converter.h"

NS_ASSUME_NONNULL_BEGIN

@interface PandocConverter : Converter

@property (readonly, copy) NSString *format;
@property (nullable, readonly, copy) NSString *header;
@property (readonly, copy) NSString *css;

- (instancetype)initWithTitle:(NSString *)title
                       format:(NSString *)format
                       header:(nullable NSString *)header
                          css:(nullable NSString *)css;

@end

NS_ASSUME_NONNULL_END
