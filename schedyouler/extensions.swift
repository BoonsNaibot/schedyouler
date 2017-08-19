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

extension Int {
    static func getRandomInt(betweenZeroAnd limit: Int) -> Int {
        assert(limit > 0)
        
        // Convert our range from [0, Int.max) to [Int.max % limit, Int.max)
        // This way, when we later % limit, there will be no bias
        let minValue = Int.max % limit
        
        var value = 0
        
        // Keep guessing until we're in the range.
        // In theory this could loop forever. It won't. A couple of times at worst
        // (mostly because we'll pick some negatives that we'll throw away)
        repeat {
            value = getRandomInteger()
        } while value < minValue
        
        return value % limit
    }
}

