//
//  errorHelper.swift
//  SwiftLintXcode
//
//  Created by yuya.tanaka on 2016/04/06.
//  Copyright © 2016年 Yuya Tanaka. All rights reserved.
//

import Foundation

func errorWithMessage(message: String) -> NSError {
    return NSError(domain: "net.ypresto.SwiftLintXcode", code: 0, userInfo: [
        NSLocalizedDescriptionKey: message
    ])
}
