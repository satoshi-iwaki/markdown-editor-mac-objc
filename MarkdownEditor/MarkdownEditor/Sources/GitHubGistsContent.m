//
//  GitHubGistsContent.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/04/22.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import "GitHubGistsContent.h"

@implementation GitHubGistsContent

- (instancetype)initWithContent:(NSString *)content
                          title:(NSString *)title
                       fileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        _title = [title copy];
        _content = [content copy];
        _fileName = [fileName copy];
    }
    return self;
}

@end
