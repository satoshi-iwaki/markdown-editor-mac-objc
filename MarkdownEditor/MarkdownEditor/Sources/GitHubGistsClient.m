//
//  GitHubGistsClient.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/04/22.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <AppAuth.h>

#import "GitHubGistsClient.h"

static NSString *const kRedirectURI = @"oauth.iwaki.info://markdown-editor/redirect/";
static NSString *const kClientID = @"ClientID";
static NSString *const kClientSecret = @"ClientSecret";
static NSString *const kGithubAuthorizationEndpoint = @"https://github.com/login/oauth/authorize";
static NSString *const kGithubTokenEndpoint = @"https://github.com/login/oauth/access_token";

@interface GitHubGistsClient ()

@property (nonatomic, nullable) OIDAuthState *authState;

@end

@interface GitHubGistsClientTask ()

@property (readonly) NSURLSessionDataTask *dataTask;
@property (nullable, copy) void (^completionBlock)(NSDictionary * _Nullable response, NSError * _Nullable error);

@end

@interface GitHubGistsClientUploadTask : GitHubGistsClientTask

- (instancetype)initWithContent:(GitHubGistsContent *)content;

@end

@implementation GitHubGistsClient {
    id<OIDAuthorizationFlowSession> _currentAuthorizationFlow;
    NSMutableArray<GitHubGistsClientTask *> *_tasks;
}

+ (GitHubGistsClient *)sharedClient {
    static GitHubGistsClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Register for GetURL events.
        NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
        [appleEventManager setEventHandler:self
                               andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                             forEventClass:kInternetEventClass
                                andEventID:kAEGetURL];
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
        configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json"};
        OIDURLSessionProvider.session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}


- (void)login {
    NSURL *authorizationEndpoint = [NSURL URLWithString:kGithubAuthorizationEndpoint];
    NSURL *tokenEndpoint = [NSURL URLWithString:kGithubTokenEndpoint];
    OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc] initWithAuthorizationEndpoint:authorizationEndpoint
                                                                                              tokenEndpoint:tokenEndpoint];
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    
    // builds authentication request
    NSArray<NSString *> *scopes = @[OIDScopeOpenID, OIDScopeProfile, @"user", @"repo", @"gist"];
    OIDAuthorizationRequest *request = [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                                                     clientId:kClientID
                                                                                 clientSecret:kClientSecret
                                                                                       scopes:scopes
                                                                                  redirectURL:redirectURI
                                                                                 responseType:OIDResponseTypeCode
                                                                         additionalParameters:nil];
    
    __weak __typeof(self) weakSelf = self;
    _currentAuthorizationFlow =
    [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                   callback:^(OIDAuthState *_Nullable authState,
                                                              NSError *_Nullable error)
     {
         if (authState) {
             NSLog(@"Got authorization tokens. Access token: %@",
                   authState.lastTokenResponse.accessToken);
         } else {
             NSLog(@"Authorization error: %@", error.localizedDescription);
         }
         [weakSelf setAuthState:authState];
         
     }];
}

- (GitHubGistsClientTask *)uploadTaskWithConent:(GitHubGistsContent *)content
                              completionHandler:(void (^)(NSDictionary * response, NSError * _Nullable error))completionHandler {
    @synchronized (self) {
        GitHubGistsClientTask *task = [[GitHubGistsClientUploadTask alloc] initWithContent:content];
        __weak __typeof(GitHubGistsClientTask) *weakTask = task;
        [_tasks addObject:task];
        
        task.completionBlock = ^(NSDictionary * _Nullable response, NSError * _Nullable error) {
            completionHandler(response, error);
            [self didCompleteTask:weakTask];
        };
        return task;
    }
}

- (void)cancelAllTasks {
    @synchronized (self) {
        for (GitHubGistsClientTask *task in _tasks) {
            [task.dataTask cancel];
        }
        [_tasks removeAllObjects];
    }
}

#pragma mark - Private Methods

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event
           withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *URLString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *URL = [NSURL URLWithString:URLString];
    [_currentAuthorizationFlow resumeAuthorizationFlowWithURL:URL];
}

- (void)didCompleteTask:(GitHubGistsClientTask *)task {
    [_tasks removeObject:task];
}

@end

@implementation GitHubGistsClientTask {
    NSURLSessionDataTask *_dataTask;
}

- (void)dealloc {
    [self cancel];
}

- (BOOL)execute {
    // override
    return NO;
}

- (BOOL)executeWithRequest:(NSURLRequest *)request {
    OIDAuthState *authState = GitHubGistsClient.sharedClient.authState;
    if (!authState.isAuthorized) {
        return NO;
    }
    
    [authState performActionWithFreshTokens:^(NSString * _Nullable accessToken,
                                              NSString * _Nullable idToken,
                                              NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to get access token, error=%@.", error);
            self.completionBlock(nil, error);
            return;
        }
        NSString *authorization = [NSString stringWithFormat:@"token %@", accessToken];
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [mutableRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
        
        NSLog(@"*** Request URL=%@", request.URL);
        NSLog(@"*** Request method=%@", request.HTTPMethod);
        NSLog(@"*** Request body=%@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
        
        @synchronized (self) {
            self->_dataTask = [NSURLSession.sharedSession dataTaskWithRequest:mutableRequest
                                                            completionHandler:^(NSData * _Nullable data,
                                                                                NSURLResponse * _Nullable response,
                                                                                NSError * _Nullable error)
                               {
                                   NSDictionary *responseJson = nil;
                                   if (error) {
                                       NSLog(@"Failed to upload file, error=%@.", error);
                                       [self didCompleteWithResponse:responseJson error:error];
                                       return;
                                   }
                                   if (data) {
                                       NSLog(@"@@@ Response body=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                       responseJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   }
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   NSLog(@"@@@ Response status code=%@", [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
                                   if ((httpResponse.statusCode / 100) != 2) {
                                       NSLog(@"Failed to upload file, status code=%@.", @(httpResponse.statusCode));
                                       [self didCompleteWithResponse:responseJson error:nil];
                                       return;
                                   }
                                   NSLog(@"Succeeded to upload file.");
                                   [self didCompleteWithResponse:responseJson error:nil];
                                   
                               }];
            [self.dataTask resume];
        }
    }];
    return YES;
}

- (void)cancel {
    @synchronized (self) {
        if (_dataTask) {
            [_dataTask cancel];
            _dataTask = nil;
        }
    }
}

- (void)didCompleteWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (self.completionBlock) {
        self.completionBlock(response, error);
    }
}

@end

@implementation GitHubGistsClientUploadTask {
    GitHubGistsContent *_content;
}

- (instancetype)initWithContent:(GitHubGistsContent *)content {
    self = [super init];
    if (self) {
        _content = content;
    }
    return self;
}

- (BOOL)execute {
    OIDAuthState *authState = GitHubGistsClient.sharedClient.authState;
    if (!authState.isAuthorized) {
        return NO;
    }
    
    // HTTP method: POST
    // URL: https://api.github.com/gists?access_token=...
    //{
    //    "description": "the description for this gist",
    //    "public": true,
    //    "files": {
    //        "file1.txt": {
    //             "content": "String file contents"
    //        }
    //    }
    //}
    
    NSDictionary *jsonObject = @{@"description": _content.title,
                                 @"public": @(YES),
                                 @"files": @{
                                         _content.fileName: @{
                                                 @"content":_content.content
                                                 }
                                         }
                                 };
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error];
    if (!body) {
        return NO;
    }
    
    NSURL *URL = [[NSURL alloc] initWithString:@"https://api.github.com/gists"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    
    return [self executeWithRequest:request];
}

@end
