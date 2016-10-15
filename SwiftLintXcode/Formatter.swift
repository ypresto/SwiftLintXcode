//
//  Formatter.swift
//  SwiftLintXcode
//
//  Created by yuya.tanaka on 2016/04/04.
//  Copyright (c) 2016 Yuya Tanaka. All rights reserved.
//

import Foundation
import Cocoa

final class Formatter {
    static var sharedInstance = Formatter()

    private static let pathExtension = "SwiftLintXcode"
    private let fileManager = FileManager.default

    private struct CursorPosition {
        let line: Int
        let column: Int
    }

    class func isFormattableDocument(_ document: NSDocument) -> Bool {
        return document.fileURL?.pathExtension.lowercased() == "swift"
    }

    func tryFormatDocument(_ document: IDESourceCodeDocument) -> Bool {
        do {
            try formatDocument(document)
            return true
        } catch let error as NSError {
            NSAlert(error: error).runModal()
        } catch {
            NSAlert(error: errorWithMessage("Unknown error occured: \(error)")).runModal()
        }
        return false
    }

    func formatDocument(_ document: IDESourceCodeDocument) throws {
        let textStorage: DVTSourceTextStorage = document.textStorage()
        let originalString = textStorage.string
        let formattedString = try formatString(originalString)
        if formattedString == originalString { return }

        let selectedRange = SwiftLintXcodeTRVSXcode.textView().selectedRange()
        let cursorPosition = cursorPositionForSelectedRange(selectedRange, textStorage: textStorage)

        textStorage.beginEditing()
        textStorage.replaceCharacters(in: NSRange(location: 0, length: textStorage.length), with: formattedString, withUndoManager: document.undoManager())
        textStorage.endEditing()

        let newLocation = locationForCursorPosition(cursorPosition, textStorage: textStorage)
        SwiftLintXcodeTRVSXcode.textView().setSelectedRange(NSRange(location: newLocation, length: 0))
    }

    private func cursorPositionForSelectedRange(_ selectedRange: NSRange, textStorage: DVTSourceTextStorage) -> CursorPosition {
        let line = textStorage.lineRange(forCharacterRange: selectedRange).location
        let column = selectedRange.location - startLocationOfLine(line, textStorage: textStorage)
        return CursorPosition(line: line, column: column)
    }

    private func locationForCursorPosition(_ cursorPosition: CursorPosition, textStorage: DVTSourceTextStorage) -> Int {
        let startOfLine = startLocationOfLine(cursorPosition.line, textStorage: textStorage)
        let locationOfNextLine = textStorage.characterRange(forLineRange: NSRange(location: cursorPosition.line + 1, length: 0)).location
        // XXX: Can reach EOF..? Cursor position may be trimmed one charactor when cursor is on EOF.
        return min(startOfLine + cursorPosition.column, locationOfNextLine - 1)
    }

    private func startLocationOfLine(_ line: Int, textStorage: DVTSourceTextStorage) -> Int {
        return textStorage.characterRange(forLineRange: NSRange(location: line, length: 0)).location
    }

    private func formatString(_ string: String) throws -> String {
        guard let workspaceRootDirectory = SwiftLintXcodeIDEHelper.currentWorkspaceURL()?.deletingLastPathComponent().path else {
            throw errorWithMessage("Cannot determine project directory.")
        }

        return try withTempporaryFile { (filePath) in
            try string.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
            let swiftlintPath = try self.getExecutableOnPath(name: "swiftlint", workingDirectory: workspaceRootDirectory)
            let task = Process()
            task.launchPath = swiftlintPath
            task.arguments = ["autocorrect", "--path", filePath]
            task.currentDirectoryPath = workspaceRootDirectory
            task.launch()
            task.waitUntilExit()
            if task.terminationStatus != 0 {
                throw errorWithMessage("Executing swiftlint exited with non-zero status.")
            }
            return try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        }
    }

    private func getExecutableOnPath(name: String, workingDirectory: String) throws -> String {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = [
            "-l", "-c", "which \(name)"
        ]
        task.currentDirectoryPath = workingDirectory
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        if task.terminationStatus != 0 {
            throw errorWithMessage("Executing `which swiftlint` exited with non-zero status.")
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let pathString = String(data: data, encoding: String.Encoding.utf8) else {
            throw errorWithMessage("Cannot read result of `which swiftlint`.")
        }
        let path = pathString.trimmingCharacters(in: CharacterSet.newlines)
        if !fileManager.isExecutableFile(atPath: path) {
            throw errorWithMessage("swiftlint at \(path) is not executable.")
        }
        return path
    }

    private func withTempporaryFile<T>(_ callback: (_ filePath: String) throws -> T) throws -> T {
        let filePath = createTemporaryPath()
        if fileManager.fileExists(atPath: filePath) {
            throw errorWithMessage("Cannot write to \(filePath), file already exists.")
        }
        defer { _ = try? fileManager.removeItem(atPath: filePath) }
        return try callback(filePath)
    }

    private func createTemporaryPath() -> String {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("SwiftLintXcode_\(UUID().uuidString).swift").path
    }
}
