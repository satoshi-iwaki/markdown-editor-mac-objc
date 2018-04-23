//
//  GitHubGistsContent.h
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/04/22.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GitHubGistsContent : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *fileName;

- (instancetype)initWithContent:(NSString *)content
                          title:(NSString *)title
                       fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
