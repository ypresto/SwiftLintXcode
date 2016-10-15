//
//  NSObject_Extension.swift
//
//  Created by yuya.tanaka on 2016/04/04.
//  Copyright (c) 2016 Yuya Tanaka. All rights reserved.
//

import Foundation

extension NSObject {
    class func pluginDidLoad(_ bundle: Bundle) {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
        	if sharedPlugin == nil {
        		sharedPlugin = SwiftLintXcode(bundle: bundle)
        	}
        }
    }
}
