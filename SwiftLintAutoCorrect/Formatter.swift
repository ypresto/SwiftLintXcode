//
//  Formatter.swift
//  SwiftLintAutoCorrect
//
//  Created by yuya.tanaka on 2016/04/04.
//  Copyright (c) 2016 Yuya Tanaka. All rights reserved.
//

import Foundation
import Cocoa

final class Formatter {
    static var sharedInstance = Formatter()
    private static let pathExtension = "swiftlintautocorrect"

    let fileManager = NSFileManager.defaultManager()
    let tempDirURL: NSURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("SwiftLintAutoCorrect-\(NSUUID().UUIDString)")

    struct CursorPosition {
        let line: Int
        let column: Int
    }


    class func isFormattableDocument(document: NSDocument) -> Bool {
        return (document.fileURL?.pathExtension?.lowercaseString == "swift") ?? false
    }

    func tryFormatDocument(document: IDESourceCodeDocument) -> Bool {
        do {
            try formatDocument(document)
            return true
        } catch let error as NSError {
            NSAlert(error: error).runModal()
        } catch {
            NSAlert(error: NSError(domain: "net.ypresto.swiftlintautocorrect", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Unknown error occured: \(error)"
            ])).runModal()
        }
        return false
    }

    func formatDocument(document: IDESourceCodeDocument) throws {
        let textStorage: DVTSourceTextStorage = document.textStorage()
        let originalString = textStorage.string
        let formattedString = try formatString(originalString)
        if formattedString == originalString { return }

        let selectedRange = SwiftLintAutoCorrectTRVSXcode.textView().selectedRange()
        let cursorPosition = cursorPositionForSelectedRange(selectedRange, textStorage: textStorage)

        textStorage.beginEditing()
        textStorage.replaceCharactersInRange(NSRange(location: 0,  length: textStorage.length), withString: formattedString, withUndoManager: document.undoManager())
        textStorage.endEditing()

        let newLocation = locationForCursorPosition(cursorPosition, textStorage: textStorage)
        SwiftLintAutoCorrectTRVSXcode.textView().setSelectedRange(NSRange(location: newLocation, length: 0))
    }

    private func cursorPositionForSelectedRange(selectedRange: NSRange, textStorage: DVTSourceTextStorage) -> CursorPosition {
        let line = textStorage.lineRangeForCharacterRange(selectedRange).location
        let column = selectedRange.location - startLocationOfLine(line, textStorage: textStorage)
        return CursorPosition(line: line, column: column)
    }

    private func locationForCursorPosition(cursorPosition: CursorPosition, textStorage: DVTSourceTextStorage) -> Int {
        let startOfLine = startLocationOfLine(cursorPosition.line, textStorage: textStorage)
        let locationOfNextLine = textStorage.characterRangeForLineRange(NSRange(location: cursorPosition.line + 1, length: 0)).location
        // XXX: Can reach EOF..? Cursor position may be trimmed one charactor when cursor is on EOF.
        return min(startOfLine + cursorPosition.column, locationOfNextLine - 1)
    }

    private func startLocationOfLine(line: Int, textStorage: DVTSourceTextStorage) -> Int {
        return textStorage.characterRangeForLineRange(NSRange(location: line, length: 0)).location
    }

    private func formatString(string: String) throws -> String {
        return try withTempporaryFile { (filePath) in
            try string.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding)
            let swiftlintPath = try self.getExecutableOnPath("swiftlint")
            let task = NSTask.launchedTaskWithLaunchPath(swiftlintPath, arguments: [
                "autocorrect", "--path", filePath
            ])
            task.waitUntilExit()
            if task.terminationStatus != 0 {
                throw NSError(domain: "net.ypresto.swiftlintautocorrect", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Executing swiftlint exited with non-zero status."
                ])
            }
            return try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        }
    }

    private func getExecutableOnPath(name: String) throws -> String {
        let pipe = NSPipe()
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = [
            "-l", "-c", "which \(name)"
        ]
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        if task.terminationStatus != 0 {
            throw NSError(domain: "net.ypresto.swiftlintautocorrect", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Executing `which swiftlint` exited with non-zero status."
            ])
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let pathString = String(data: data, encoding: NSUTF8StringEncoding) else {
            throw NSError(domain: "net.ypresto.swiftlintautocorrect", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Cannot read result of `which swiftlint`."
            ])
        }
        let path = pathString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        if !fileManager.isExecutableFileAtPath(path) {
            throw NSError(domain: "net.ypresto.swiftlintautocorrect", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "swiftlint at \(path) is not executable."
            ])
        }
        return path
    }

    private func withTempporaryFile<T>(@noescape callback: (filePath: String) throws -> T) throws -> T {
        try ensureTemporaryDirectory()
        let filePath = createTemporaryPath()
        if fileManager.fileExistsAtPath(filePath) {
            throw NSError(domain: "net.ypresto.swiftlintautocorrect", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Cannot write to \(filePath), file already exists."
            ])
        }
        defer { _ = try? fileManager.removeItemAtPath(filePath) }
        return try callback(filePath: filePath)
    }

    private func createTemporaryPath() -> String {
        return tempDirURL.URLByAppendingPathComponent(NSUUID().UUIDString).path! + ".swift"
    }

    private func ensureTemporaryDirectory() throws {
        if fileManager.fileExistsAtPath(tempDirURL.path!) { return }
        try fileManager.createDirectoryAtURL(tempDirURL, withIntermediateDirectories: true, attributes: nil)
    }
}
