//
//  ConverterManager.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import "ConverterManager.h"
#import "TextConverter.h"
#import "GfmConverter.h"
#import "MarkdownConverter.h"
#import "PhpMarkdownConverter.h"
#import "StrictMarkdownConverter.h"
#import "Logger.h"
#import "GCDWebServer/GCDWebServer.h"
#import "GCDWebServer/GCDWebServerDataResponse.h"

NSNotificationName ConverterManagerDidChangeContentNotification = @"ConverterManagerDidChangeContentNotification";

@implementation ConverterManager {
    GCDWebServer *_webServer;
    NSData *_data;
    NSString *_string;
    NSUInteger _selectedConverterIndex;
    NSArray<TextConverter *> *_converters;
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _converters = @[[[GfmConverter alloc] init],
                        [[MarkdownConverter alloc] init],
                        [[PhpMarkdownConverter alloc] init],
                        [[StrictMarkdownConverter alloc] init],
                        ];
        self.selectedConverterIndex = 0;
        [self startWebServer];
    }
    return self;
}

- (NSURL *)url {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:_webServer.serverURL.absoluteString];
    urlComponents.path = @"/index.html";
    return urlComponents.URL;
}

- (NSString *)html {
    @synchronized (self) {
        return self.selectedConverter.html;
    }
}

- (NSArray<NSString *> *)converters {
    @synchronized (self) {
        NSMutableArray *converters = [@[] mutableCopy];
        for (TextConverter *converter in _converters) {
            [converters addObject:converter.title];
        }
        return converters;
    }
}

- (NSUInteger)selectedConverterIndex {
    @synchronized (self) {
        return _selectedConverterIndex;
    }
}

- (void)setSelectedConverterIndex:(NSUInteger)selectedConverterIndex {
    @synchronized (self) {
        _selectedConverterIndex = selectedConverterIndex;
        if (_string) {
            [self relaod];
        }
    }
}

- (TextConverter *)selectedConverter {
    @synchronized (self) {
        return _converters[_selectedConverterIndex];
    }
}

- (void)setContentWithString:(NSString *)string {
    @synchronized (self) {
        TextConverter *converter = self.selectedConverter;
        [converter setContentWithString:string];
        LogV(@"*** HTML ***");
        LogV(@"%@", converter.html);
        _string = string;
        [self didChangeContent];
    }
}

- (void)didChangeContent {
    [NSNotificationCenter.defaultCenter postNotificationName:ConverterManagerDidChangeContentNotification
                                                      object:nil];
}

- (void)relaod {
    [self setContentWithString:_string];
}

- (void)startWebServer {
    __unsafe_unretained typeof(self) weakSelf = self;
    [GCDWebServer setLogLevel:4];
    _webServer = [[GCDWebServer alloc] init];
    [_webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request)
    {
        NSString *path = [NSString pathWithComponents:@[NSBundle.mainBundle.resourcePath,
                                                        request.path]];
        if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
            return [GCDWebServerResponse responseWithStatusCode:404];
        }
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSString *contentType = @"text/plain";
        if ([path.pathExtension isEqualToString:@"js"]) {
            contentType = @"text/javascript";
        } else if ([path.pathExtension isEqualToString:@"css"]) {
            contentType = @"text/css";
        } else if ([path.pathExtension isEqualToString:@"html"]) {
            contentType = @"text/html";
        }
        return [GCDWebServerDataResponse responseWithData:data contentType:contentType];
    }];
    [_webServer addHandlerForMethod:@"GET"
                               path:@"/index.html"
                       requestClass:[GCDWebServerRequest class]
                       processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request)
    {
        return [GCDWebServerDataResponse responseWithData:weakSelf->_data contentType:@"text/html"];
    }];
    [_webServer startWithPort:8080 bonjourName:nil];
}

@end
