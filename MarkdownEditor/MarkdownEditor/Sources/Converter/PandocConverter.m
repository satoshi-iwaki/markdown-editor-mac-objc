//
//  PandocConverter.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import "PandocConverter.h"
#import "Logger.h"

@implementation PandocConverter {
    NSPipe *_pipe;
    NSTask *_task;
    NSData *_data;
    NSString *_html;
    NSString *_title;
    NSString *_format;
    NSString *_header;
    NSString *_css;
}

- (instancetype)initWithTitle:(NSString *)title
                       format:(NSString *)format
                       header:(nullable NSString *)header
                          css:(nullable NSString *)css {
    self = [super initWithTitle:title];
    if (self) {
        _format = [format copy];
        _header = [header copy];
        _css = [css copy];
        _html = @"<html><body></body></html>";
    }
    return self;
}

- (NSString *)html {
    return _html;
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

- (void)setContentWithString:(NSString *)string {
    @synchronized (self) {
        NSString *command = [self commandWithString:string];
        
        LogD(@"Command : %@", command);
        _pipe = [[NSPipe alloc] init];
        _task = [[NSTask alloc] init];
        _task.standardOutput = _pipe;
        _task.launchPath = @"/bin/sh";
        _task.environment = @{@"PATH" : NSBundle.mainBundle.resourcePath};
        _task.arguments = @[@"-l", @"-c", command];
        
        [_task launch];
        [_task waitUntilExit];
        
        _data = [_pipe.fileHandleForReading readDataToEndOfFile];
        _html = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        
        LogD(@"*** HTML ***");
        LogD(@"%@", _html);
    }
}

- (NSString *)commandWithString:(NSString *)string {
    NSMutableArray<NSString *> *params = [@[] mutableCopy];
    [params addObject:[NSString stringWithFormat:@"echo '%@' | pandoc", string]];
    [params addObject:[NSString stringWithFormat:@"-f %@", self.format]];
    [params addObject:[NSString stringWithFormat:@"-c %@", self.css]];
    [params addObject:@"-t html"];
    [params addObject:@"-s"];
    if (_header) {
        NSString *path = [NSBundle.mainBundle pathForResource:_header ofType:@""];
        [params addObject:[NSString stringWithFormat:@"--include-in-header='%@'", path]];
    }
    return [params componentsJoinedByString:@" "];
}

@end
