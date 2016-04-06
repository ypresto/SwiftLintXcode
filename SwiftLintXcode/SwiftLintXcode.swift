//
//  SwiftLintXcode.swift
//
//  Created by yuya.tanaka on 2016/04/04.
//  Copyright (c) 2016 Yuya Tanaka. All rights reserved.
//

import AppKit

var sharedPlugin: SwiftLintXcode?

class SwiftLintXcode: NSObject {

    var bundle: NSBundle
    lazy var center = NSNotificationCenter.defaultCenter()

    var enableMenuItem: NSMenuItem!
    var disableMenuItem: NSMenuItem!

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        center.addObserver(self, selector: #selector(SwiftLintXcode.onApplicationDidFinishLaunching), name: NSApplicationDidFinishLaunchingNotification, object: nil)
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

        let pluginMenu = NSMenu(title:"SwiftLintXcode")
        let pluginMenuItem = NSMenuItem(title:"SwiftLintXcode", action: nil, keyEquivalent: "")
        pluginMenuItem.submenu = pluginMenu

        let autoCorrectMenuItem = NSMenuItem(title:"AutoCorrect Current File", action:#selector(SwiftLintXcode.doAutoCorrect), keyEquivalent:"")
        autoCorrectMenuItem.target = self
        pluginMenu.addItem(autoCorrectMenuItem)

        let enableMenuItem = NSMenuItem(title:"Enable AutoCorrect on Save", action:#selector(SwiftLintXcode.doEnableFormatOnSave), keyEquivalent:"")
        enableMenuItem.target = self
        pluginMenu.addItem(enableMenuItem)
        self.enableMenuItem = enableMenuItem

        let disableMenuItem = NSMenuItem(title:"Disable AutoCorrect on Save", action:#selector(SwiftLintXcode.doDisableFormatOnSave), keyEquivalent:"")
        disableMenuItem.target = self
        pluginMenu.addItem(disableMenuItem)
        self.disableMenuItem = disableMenuItem

        item.submenu!.addItem(NSMenuItem.separatorItem())
        item.submenu!.addItem(pluginMenuItem)

        updateMenuVisibility()
    }

    func doAutoCorrect() {
        let sourceCodeDocument: IDESourceCodeDocument = SwiftLintXcodeTRVSXcode.sourceCodeDocument()
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
