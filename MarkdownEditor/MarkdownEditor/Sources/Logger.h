//
//  Logger.h
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/03/07.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

#define LogE(...) NSLog(__VA_ARGS__)
#define LogW(...) NSLog(__VA_ARGS__)
#define LogI(...) NSLog(__VA_ARGS__)
#define LogD(...) NSLog(__VA_ARGS__)

#else

#define LogE(...)
#define LogW(...)
#define LogI(...)
#define LogD(...)

#endif

