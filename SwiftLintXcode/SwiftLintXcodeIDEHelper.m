//
//  SwiftLintXcodeIDEHelper.m
//  SwiftLintXcode
//
//  Created by yuya.tanaka on 2016/04/06.
//  Copyright © 2016年 Yuya Tanaka. All rights reserved.
//

#import "SwiftLintXcodeIDEHelper.h"
#import "SwiftLintXcodeTRVSXcode.h"
@import Cocoa;

@implementation SwiftLintXcodeIDEHelper

+ (nullable NSURL *)currentWorkspaceURL
{
    IDEWorkspaceWindowController *workspaceWindowController = (IDEWorkspaceWindowController *)[[NSApp keyWindow] windowController];
    IDEWorkspace *workspace = [workspaceWindowController valueForKey:@"_workspace"];
    return workspace.representingFilePath.fileURL;
}

@end
