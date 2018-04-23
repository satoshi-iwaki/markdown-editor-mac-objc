//
//  MainWindowController.h
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/03/03.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConverterManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainWindowController : NSWindowController

@property (copy, readonly) NSArray<NSString *> *converters;
@property NSUInteger selectedConverterIndex;

@end

NS_ASSUME_NONNULL_END
