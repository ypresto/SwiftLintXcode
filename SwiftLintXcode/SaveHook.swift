//
//  SaveHook.swift
//  SwiftLintXcode
//
//  Created by yuya.tanaka on 2016/04/04.
//  Copyright (c) 2016 Yuya Tanaka. All rights reserved.
//

// http://blog.waft.me/method-swizzling/

import Foundation
import Cocoa

final class SaveHook {

    private static var swizzled = false
    static var enabled = true

    private init() {
        fatalError()
    }

    class func swizzle() {
        if swizzled { return }
        swizzled = true

        let fromMethod = class_getInstanceMethod(NSDocument.self, #selector(NSDocument.save(withDelegate:didSave:contextInfo:)))
        let toMethod = class_getInstanceMethod(NSDocument.self, #selector(NSDocument.swiftLintXcodeSaveDocument(delegate:didSaveSelector:contextInfo:)))
        method_exchangeImplementations(fromMethod, toMethod)
    }

    class func tryOnSaveDocument(_ document: NSDocument) -> Bool {
        if !enabled { return true }
        if !Formatter.isFormattableDocument(document) { return true }
        let sourceCodeDocument: IDESourceCodeDocument = SwiftLintXcodeTRVSXcode.sourceCodeDocument()
        guard sourceCodeDocument == document else { return true }
        return Formatter.sharedInstance.tryFormatDocument(sourceCodeDocument)
    }
}

// https://github.com/travisjeffery/ClangFormat-Xcode/blob/a22114907592fb5d5b1043a4919d7be3e1496741/ClangFormat/NSDocument+TRVSClangFormat.m
extension NSDocument {

    dynamic func swiftLintXcodeSaveDocument(delegate: AnyObject?, didSaveSelector: Selector, contextInfo: UnsafeMutableRawPointer) -> Void {
        if SaveHook.tryOnSaveDocument(self) {
            // NOTE: Call original method
            swiftLintXcodeSaveDocument(delegate: delegate, didSaveSelector: didSaveSelector, contextInfo: contextInfo)
        }
    }
}
