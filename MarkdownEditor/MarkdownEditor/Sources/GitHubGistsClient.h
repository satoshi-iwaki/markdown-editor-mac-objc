//
//  GitHubGistsClient.h
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/04/22.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitHubGistsContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GitHubGistsClientTask : NSObject

- (BOOL)execute;

- (void)cancel;

@end

@interface GitHubGistsClient : NSObject

@property (class, readonly, strong) GitHubGistsClient *sharedClient;

- (void)login;

- (GitHubGistsClientTask *)uploadTaskWithConent:(GitHubGistsContent *)content
                              completionHandler:(void (^)(NSDictionary * response, NSError * _Nullable error))completionHandler;

- (void)cancelAllTasks;

@end

NS_ASSUME_NONNULL_END
