//
//  MainWindowController.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/03/03.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import "MainWindowController.h"
#import "GitHubGistsClient.h"

@interface MainWindowController () {
}

@end

@implementation MainWindowController

- (NSArray<NSString *> *)converters {
    return ConverterManager.sharedInstance.converters;
}

- (NSUInteger)selectedConverterIndex {
    return ConverterManager.sharedInstance.selectedConverterIndex;
}

- (void)setSelectedConverterIndex:(NSUInteger)selectedFormatIndex {
    ConverterManager.sharedInstance.selectedConverterIndex = selectedFormatIndex;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

- (IBAction)loginButtonClicked:(id)sender {
    [GitHubGistsClient.sharedClient login];
}

@end
