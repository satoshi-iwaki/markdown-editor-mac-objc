//
//  MarkdownConverter.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import "MarkdownConverter.h"

@implementation MarkdownConverter

- (instancetype)init {
    self = [super initWithTitle:@"Markdown"
                         format:@"markdown"
                         header:@"markdown-header.txt"
                            css:@"markdown.css"];
    if (self) {
    }
    return self;
}

- (NSString *)formattedStringWithString:(NSString *)string format:(TextConverterFormat)format {
    switch (format) {
        case TextConverterFormatBold:
            return [NSString stringWithFormat:@"**%@**", string];
        case TextConverterFormatItalic:
            return [NSString stringWithFormat:@"*%@*", string];
        case TextConverterFormatStrikeThrough:
            return [NSString stringWithFormat:@"~~%@~~", string];
        case TextConverterFormatCode: {
            return [NSString stringWithFormat:@"```\n%@\n```", string];
        }
        case TextConverterFormatLink: {
            return [NSString stringWithFormat:@"[%@](url)", string];
        }
        case TextConverterFormatQuote: {
            NSArray<NSString *> *lines = [string componentsSeparatedByString:@"\n"];
            NSMutableString *formattedString = [@"" mutableCopy];
            for (NSString *line in lines) {
                [formattedString appendString:@"> "];
                [formattedString appendString:line];
                [formattedString appendString:@"\n"];
            }
            return formattedString;
        }
        case TextConverterFormatListBulleted: {
            NSArray<NSString *> *lines = [string componentsSeparatedByString:@"\n"];
            NSMutableString *formattedString = [@"" mutableCopy];
            for (NSString *line in lines) {
                [formattedString appendString:@"- "];
                [formattedString appendString:line];
                [formattedString appendString:@"\n"];
            }
            return formattedString;
        }
        case TextConverterFormatListNumbered: {
            NSArray<NSString *> *lines = [string componentsSeparatedByString:@"\n"];
            NSMutableString *formattedString = [@"" mutableCopy];
            for (NSString *line in lines) {
                [formattedString appendString:@"1. "];
                [formattedString appendString:line];
                [formattedString appendString:@"\n"];
            }
            return formattedString;
        }
        default:
            break;
    }
    return string;
}

@end
