//
//  SwiftLintAutoCorrect.swift
//
//  Created by yuya.tanaka on 2016/04/04.
//  Copyright (c) 2016 Yuya Tanaka. All rights reserved.
//

import AppKit

var sharedPlugin: SwiftLintAutoCorrect?

class SwiftLintAutoCorrect: NSObject {

    var bundle: NSBundle
    lazy var center = NSNotificationCenter.defaultCenter()

    var enableMenuItem: NSMenuItem!
    var disableMenuItem: NSMenuItem!

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        center.addObserver(self, selector: #selector(SwiftLintAutoCorrect.onApplicationDidFinishLaunching), name: NSApplicationDidFinishLaunchingNotification, object: nil)
    }

    deinit {
        removeObserver()
    }

    private func removeObserver() {
        center.removeObserver(self)
    }

    func onApplicationDidFinishLaunching() {
        SaveHook.swizzle()
        createMenuItems()
    }

    private func createMenuItems() {
        removeObserver()

        guard let item = NSApp.mainMenu!.itemWithTitle("Edit") else { return }

        let pluginMenu = NSMenu(title:"SwiftLint Auto Correct")
        let pluginMenuItem = NSMenuItem(title:"SwiftLint Auto Correct", action: nil, keyEquivalent: "")
        pluginMenuItem.submenu = pluginMenu

        let autoCorrectMenuItem = NSMenuItem(title:"Auto Correct", action:#selector(SwiftLintAutoCorrect.doAutoCorrect), keyEquivalent:"")
        autoCorrectMenuItem.target = self
        pluginMenu.addItem(autoCorrectMenuItem)

        let enableMenuItem = NSMenuItem(title:"Enable Format on Save", action:#selector(SwiftLintAutoCorrect.doEnableFormatOnSave), keyEquivalent:"")
        enableMenuItem.target = self
        pluginMenu.addItem(enableMenuItem)
        self.enableMenuItem = enableMenuItem

        let disableMenuItem = NSMenuItem(title:"Disable Format on Save", action:#selector(SwiftLintAutoCorrect.doDisableFormatOnSave), keyEquivalent:"")
        disableMenuItem.target = self
        pluginMenu.addItem(disableMenuItem)
        self.disableMenuItem = disableMenuItem

        item.submenu!.addItem(NSMenuItem.separatorItem())
        item.submenu!.addItem(pluginMenuItem)

        updateMenuVisibility()
    }

    func doAutoCorrect() {
        let sourceCodeDocument: IDESourceCodeDocument = SwiftLintAutoCorrectTRVSXcode.sourceCodeDocument()
        guard Formatter.isFormattableDocument(sourceCodeDocument) else { return }
        Formatter.sharedInstance.tryFormatDocument(sourceCodeDocument)
    }

    func doEnableFormatOnSave() {
        SaveHook.enabled = true
        updateMenuVisibility()
    }

    func doDisableFormatOnSave() {
        SaveHook.enabled = false
        updateMenuVisibility()
    }

    func updateMenuVisibility() {
        self.enableMenuItem.hidden = SaveHook.enabled
        self.disableMenuItem.hidden = !SaveHook.enabled
    }
}
