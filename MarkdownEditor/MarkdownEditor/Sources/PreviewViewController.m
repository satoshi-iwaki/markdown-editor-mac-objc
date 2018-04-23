//
//  PreviewViewController.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "PreviewViewController.h"
#import "ConverterManager.h"
#import "PreferenceManager.h"

@interface PreviewViewController () <WKNavigationDelegate, WKUIDelegate>

@property (weak) IBOutlet WKWebView *webView;

@end

@implementation PreviewViewController {
    WKNavigation *_navigation;
    NSRect _visibleRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didChangeContentNotification:)
                                               name:ConverterManagerDidChangeContentNotification
                                             object:nil];
    
    _visibleRect = NSZeroRect;
    [self relaodHtml];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.webView scrollRectToVisible:_visibleRect];
}

#pragma mark - Notification Handler

- (void)didChangeContentNotification:(NSNotification *)notification {
    if (PreferenceManager.sharedManager.autoReloadEnabled) {
        [self relaodHtml];
    }
}

#pragma mark - Private Methods

- (void)relaodHtml {
    _visibleRect = self.webView.visibleRect;
    _navigation = [self.webView loadHTMLString:ConverterManager.sharedInstance.html
                                       baseURL:NSBundle.mainBundle.resourceURL];
}


#pragma mark - Handler

- (IBAction)reloadButtonClicked:(NSButton *)sender {
    [self relaodHtml];
}

@end
