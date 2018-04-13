//
//  TextConverter.h
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TextConverterFormat) {
    TextConverterFormatBold,
    TextConverterFormatItalic,
    TextConverterFormatStrikeThrough,
    TextConverterFormatQuote,
    TextConverterFormatCode,
    TextConverterFormatLink,
    TextConverterFormatListBulleted,
    TextConverterFormatListNumbered
};

@interface TextConverter : NSObject

@property (readonly, copy) NSString *title;
@property (nullable, readonly, copy) NSString *sample;
@property (readonly, copy) NSString *html;
@property (readonly, copy) NSData *data;

- (instancetype)initWithTitle:(NSString *)title;

- (NSString *)formattedStringWithString:(NSString *)string format:(TextConverterFormat)format;

- (void)setContentWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
