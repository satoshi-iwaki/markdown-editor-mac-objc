//
//  EditorViewController.m
//  MarkdownEditor
//
//  Created by Iwaki Satoshi on 2018/02/27.
//  Copyright © 2018年 Satoshi Iwaki. All rights reserved.
//

#import "EditorViewController.h"
#import "ConverterManager.h"
#import "TextConverter.h"
#import "GitHubGistsClient.h"
#import "GitHubGistsContent.h"

@interface EditorViewController () <NSTextViewDelegate> {
    NSString *_filePath;
    BOOL _dirty;
}

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *titleTextField;

@end

@implementation EditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.textView.string = [self loadSample];
    [ConverterManager.sharedInstance setContentWithString:self.textView.string];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark - NSTextDelegate

- (void)textDidEndEditing:(NSNotification *)notification {
    [ConverterManager.sharedInstance setContentWithString:self.textView.string];
    _dirty = YES;
}

- (void)textDidChange:(NSNotification *)notification {
    [ConverterManager.sharedInstance setContentWithString:self.textView.string];
    _dirty = YES;
}

#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray<NSValue *> *)affectedRanges replacementStrings:(nullable NSArray<NSString *> *)replacementStrings {
    return YES;
}

#pragma mark - Formatter Handler

- (IBAction)boldButtonClicked:(NSButton *)sender {
    NSRange range = self.textView.selectedRange;
    if (range.length == 0) {
        return;
    }
    NSString *selectedString = [self.textView.string substringWithRange:range];
    NSString *string = [ConverterManager.sharedInstance.selectedConverter formattedStringWithString:selectedString
                                                                                            format:TextConverterFormatBold];
    [self replaceCharactersInRange:range withString:string];
}

- (IBAction)strikeThroughButtonClicked:(NSButton *)sender {
    NSRange range = self.textView.selectedRange;
    if (range.length == 0) {
        return;
    }
    NSString *selectedString = [self.textView.string substringWithRange:range];
    NSString *string = [ConverterManager.sharedInstance.selectedConverter formattedStringWithString:selectedString
                                                                                            format:TextConverterFormatStrikeThrough];
    [self replaceCharactersInRange:range withString:string];
}

- (IBAction)italicButtonClicked:(NSButton *)sender {
    NSRange range = self.textView.selectedRange;
    if (range.length == 0) {
        return;
    }
    NSString *selectedString = [self.textView.string substringWithRange:range];
    NSString *string = [ConverterManager.sharedInstance.selectedConverter formattedStringWithString:selectedString
                                                                                            format:TextConverterFormatItalic];
    [self replaceCharactersInRange:range withString:string];
}

- (IBAction)quoteButtonClicked:(NSButton *)sender {
    NSRange range = self.textView.selectedRange;
    if (range.length == 0) {
        return;
    }
    NSString *selectedString = [self.textView.string substringWithRange:range];
    NSString *string = [ConverterManager.sharedInstance.selectedConverter formattedStringWithString:selectedString
                                                                                            format:TextConverterFormatQuote];
    [self replaceCharactersInRange:range withString:string];
}

- (IBAction)codeButtonClicked:(NSButton *)sender {
    NSRange range = self.textView.selectedRange;
    if (range.length == 0) {
        return;
    }
    NSString *selectedString = [self.textView.string substringWithRange:range];
    NSString *string = [ConverterManager.sharedInstance.selectedConverter formattedStringWithString:selectedString
                                                                                            format:TextConverterFormatCode];
    [self replaceCharactersInRange:range withString:string];
}

- (IBAction)insertLinkButtonClicked:(NSButton *)sender {
    NSRange range = self.textView.selectedRange;
    if (range.length == 0) {
        return;
    }
    NSString *selectedString = [self.textView.string substringWithRange:range];
    NSString *string = [ConverterManager.sharedInstance.selectedConverter formattedStringWithString:selectedString
                                                                                            format:TextConverterFormatLink];
    [self replaceCharactersInRange:range withString:string];
}

- (IBAction)listBulletedButtonClicked:(NSButton *)sender {
    NSRange range = self.textView.selectedRange;
    if (range.length == 0) {
        return;
    }
    NSString *selectedString = [self.textView.string substringWithRange:range];
    NSString *string = [ConverterManager.sharedInstance.selectedConverter formattedStringWithString:selectedString
                                                                                            format:TextConverterFormatListBulleted];
    [self replaceCharactersInRange:range withString:string];
}

- (IBAction)listNumberedButtonClicked:(NSButton *)sender {
    NSRange range = self.textView.selectedRange;
    if (range.length == 0) {
        return;
    }
    NSString *selectedString = [self.textView.string substringWithRange:range];
    NSString *string = [ConverterManager.sharedInstance.selectedConverter formattedStringWithString:selectedString
                                                                                            format:TextConverterFormatListNumbered];
    [self replaceCharactersInRange:range withString:string];
}

#pragma mark - Menu Handler

- (IBAction)newDocument:(id)sender {
    if (!_dirty) {
        [self newFile];
        return;
    }
    NSAlert *alert = [[NSAlert alloc] init];
    alert.informativeText = @"Your changes will be lost if you don't save them.";
    alert.messageText = @"Do you want to save the changes you made to New file?";
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Don't Save"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSAlertFirstButtonReturn: {  // Save
                if ([self saveFile]) {
                    return;
                }
                [self showSaveFilePanelWithCompletionHandler:^(BOOL result) {
                    if (result) {
                        [self newFile];
                    }
                }];
                break;
            }
            case NSAlertThirdButtonReturn:  // Don't Save
                [self newFile];
                break;
            case NSAlertSecondButtonReturn: // Cancel
            default:
                break;
        }
    }];
}

- (IBAction)openDocument:(id)sender {
    if (!_dirty) {
        [self showOpenFilePanel];
        return;
    }
    NSAlert *alert = [[NSAlert alloc] init];
    alert.informativeText = @"Your changes will be lost if you don't save them.";
    alert.messageText = @"Do you want to save the changes you made to New file?";
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Don't Save"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSAlertFirstButtonReturn: {  // Save
                if ([self saveFile]) {
                    return;
                }
                [self showSaveFilePanelWithCompletionHandler:^(BOOL result) {
                    if (result) {
                        [self showOpenFilePanel];
                    }
                }];
                break;
            }
            case NSAlertThirdButtonReturn:  // Don't Save
                [self showOpenFilePanel];
                break;
            case NSAlertSecondButtonReturn: // Cancel
            default:
                break;
        }
    }];
}

- (IBAction)saveDocument:(id)sender {
    if ([self saveFile]) {
        return;
    }
    [self showSaveFilePanel];
}

- (IBAction)saveDocumentAs:(id)sender {
    [self showSaveFilePanel];
}

- (IBAction)uploadDocument:(id)sender {
    GitHubGistsContent *content = [[GitHubGistsContent alloc] initWithContent:[self documentBody]
                                                                        title:[self documentTitle]
                                                                     fileName:[self fileName]];
    GitHubGistsClientTask *task = [GitHubGistsClient.sharedClient uploadTaskWithConent:content
                                                                     completionHandler:^(NSDictionary * _Nonnull response, NSError * _Nullable error)
    {
        if (error) {
            [self showAlertWithTitle:@"Failed to upload." message:error.localizedDescription];
            return;
        }
        [self showAlertWithTitle:@"Succeded to upload." message:@""];
    }];

    [task execute];
}

#pragma mark - Private Methods

- (NSString *)loadSample {
    return ConverterManager.sharedInstance.selectedConverter.sample;
}

- (NSString *)documentTitle {
    NSString *title = self.titleTextField.stringValue;
    if (!title) {
        title = @"Unknown";
    }
    return title;
}

- (NSString *)documentBody {
    NSString *body = self.textView.string;
    if (!body) {
        body = @"Unknown";
    }
    return body;
}

- (NSString *)fileName {
    if (!_filePath) {
        return @"Unknown.md";
    }
    return [_filePath lastPathComponent];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string {
    if ([self.textView shouldChangeTextInRange:range replacementString:string]) {
        [self.textView replaceCharactersInRange:range withString:string];
        [self.textView didChangeText];
        _dirty = YES;
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    if (!NSThread.isMainThread) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self showAlertWithTitle:title message:message];
        });
        return;
    }
    NSAlert *alert = [[NSAlert alloc] init];
    alert.informativeText = title;
    alert.messageText = message;
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSAlertFirstButtonReturn:  // OK
            default:
                break;
        }
    }];
}

- (void)showOpenFilePanelWithCompletionHandler:(void (^)(BOOL result))handler {
    NSString *path = _filePath;
    if (!path) {
        path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO).firstObject;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.directoryURL = [NSURL fileURLWithPath:path];
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
    panel.canSelectHiddenExtension = YES;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        BOOL success = NO;
        if (result == NSModalResponseOK) {
            self->_filePath = panel.URL.path;
            success = [self openFile];
        }
        handler(success);
    }];
}

- (void)showOpenFilePanel {
    [self showOpenFilePanelWithCompletionHandler:^(BOOL result) {
        ;
    }];
}

- (void)showSaveFilePanelWithCompletionHandler:(void (^)(BOOL result))handler {
    NSString *path = _filePath;
    if (!path) {
        path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO).firstObject;
    }
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.directoryURL = [NSURL fileURLWithPath:path];
    panel.allowedFileTypes = @[@"md", @"markdwon"];
    panel.canSelectHiddenExtension = YES;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        BOOL success = NO;
        if (result == NSModalResponseOK) {
            self->_filePath = panel.URL.path;
            success = [self saveFile];
        }
        handler(success);
    }];
}

- (void)showSaveFilePanel {
    [self showSaveFilePanelWithCompletionHandler:^(BOOL result) {
        ;
    }];
}

- (void)newFile {
    self.textView.string = @"New File";
    [ConverterManager.sharedInstance setContentWithString:self.textView.string];
    _filePath = nil;
    _dirty = NO;
}

- (BOOL)openFile {
    if (!_filePath) {
        return NO;
    }
    BOOL isDirectory = NO;
    if (![NSFileManager.defaultManager fileExistsAtPath:_filePath isDirectory:&isDirectory]) {
        return NO;
    }
    if (isDirectory) {
        return NO;
    }
    NSData *data = [NSData dataWithContentsOfFile:_filePath];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!string) {
        return NO;
    }
    
    _dirty = NO;
    self.textView.string = string;
    [ConverterManager.sharedInstance setContentWithString:self.textView.string];
    return YES;
}

- (BOOL)saveFile {
    if (!_filePath) {
        return NO;
    }
    if ([NSFileManager.defaultManager fileExistsAtPath:_filePath]) {
        NSError *error = nil;
        if (![NSFileManager.defaultManager removeItemAtPath:_filePath error:&error]) {
            return NO;
        }
    }
    
    _dirty = NO;
    NSData *data = [self.textView.string dataUsingEncoding:NSUTF8StringEncoding];
    return [data writeToFile:_filePath atomically:YES];
}

@end
