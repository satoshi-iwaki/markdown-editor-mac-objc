//
//  PhpMarkdownConverter.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import "PhpMarkdownConverter.h"

@implementation PhpMarkdownConverter

- (instancetype)init {
    self = [super initWithTitle:@"PHP Markdown Extra"
                         format:@"markdown_phpextra"
                         header:nil
                            css:@"markdown.css"];
    if (self) {
        ;
    }
    return self;
}

- (NSString *)formattedStringWithString:(NSString *)string format:(ConverterFormat)format {
    switch (format) {
        case ConverterFormatBold:
            return [NSString stringWithFormat:@"**%@**", string];
        case ConverterFormatItalic:
            return [NSString stringWithFormat:@"*%@*", string];
        case ConverterFormatStrikeThrough:
            return [NSString stringWithFormat:@"~~%@~~", string];
        case ConverterFormatCode: {
            return [NSString stringWithFormat:@"```\n%@\n```", string];
        }
        case ConverterFormatLink: {
            return [NSString stringWithFormat:@"[%@](url)", string];
        }
        case ConverterFormatQuote: {
            NSArray<NSString *> *lines = [string componentsSeparatedByString:@"\n"];
            NSMutableString *formattedString = [@"" mutableCopy];
            for (NSString *line in lines) {
                [formattedString appendString:@"> "];
                [formattedString appendString:line];
                [formattedString appendString:@"\n"];
            }
            return formattedString;
        }
        case ConverterFormatListBulleted: {
            NSArray<NSString *> *lines = [string componentsSeparatedByString:@"\n"];
            NSMutableString *formattedString = [@"" mutableCopy];
            for (NSString *line in lines) {
                [formattedString appendString:@"- "];
                [formattedString appendString:line];
                [formattedString appendString:@"\n"];
            }
            return formattedString;
        }
        case ConverterFormatListNumbered: {
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
