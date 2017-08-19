//
//  extensions.swift
//  schedyouler
//
//  Created by divine on 8/19/17.
//  Copyright © 2017 divine ikenna. All rights reserved.
//  Special Thanks to Nate Cook
//

import Foundation

/* TODO: Update for Swift 4 */

extension Integer {
    fileprivate static func getRandomInteger() -> Self {
        var result: Self = 0
        let _ = withUnsafeMutablePointer(to: &result) { resultPtr in
            resultPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size) { bytePtr in
                SecRandomCopyBytes(nil, MemoryLayout<Self>.size, bytePtr)
            }
        }
        return result
    }
}

