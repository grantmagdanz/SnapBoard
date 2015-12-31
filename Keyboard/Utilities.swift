//
//  Utilities.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/22/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Foundation
import UIKit

// from https://gist.github.com/berkus/8a9e104f8aac5d025eb5
//func memoize<T: Hashable, U>( body: ( (T)->U, T ) -> U ) -> (T) -> U {
//    var memo = Dictionary<T, U>()
//    var result: ((T)->U)!
//    
//    result = { x in
//        if let q = memo[x] { return q }
//        let r = body(result, x)
//        memo[x] = r
//        return r
//    }
//    
//    return result
//}

//func memoize<S:Hashable, T:Hashable, U>(fn : (S, T) -> U) -> (S, T) -> U {
//    var cache = Dictionary<FunctionParams<S,T>, U>()
//    func memoized(val1 : S, val2: T) -> U {
//        let key = FunctionParams(x: val1, y: val2)
//        if cache.indexForKey(key) == nil {
//            cache[key] = fn(val1, val2)
//        }
//        return cache[key]!
//    }
//    return memoized
//}

func memoize<T:Hashable, U>(fn : T -> U) -> T -> U {
    var cache = [T:U]()
    return {
        (val : T) -> U in
        let value = cache[val]
        if value != nil {
            return value!
        } else {
            let newValue = fn(val)
            cache[val] = newValue
            return newValue
        }
    }
}

//let fibonacci = memoize {
//    fibonacci, n in
//    n < 2 ? Double(n) : fibonacci(n-1) + fibonacci(n-2)
//}

//func memoize<T:Hashable, U>(fn : T -> U) -> (T -> U) {
//    var cache = Dictionary<T, U>()
//    func memoized(val : T) -> U {
//        if !cache.indexForKey(val) {
//            cache[val] = fn(val)
//        }
//        return cache[val]!
//    }
//    return memoized
//}

var profile: ((id: String) -> Double?) = {
    var counterForName = Dictionary<String, Double>()
    var isOpen = Dictionary<String, Double>()
    
    return { (id: String) -> Double? in
        if let startTime = isOpen[id] {
            let diff = CACurrentMediaTime() - startTime
            if let currentCount = counterForName[id] {
                counterForName[id] = (currentCount + diff)
            }
            else {
                counterForName[id] = diff
            }
            
            isOpen[id] = nil
        }
        else {
            isOpen[id] = CACurrentMediaTime()
        }
        
        return counterForName[id]
    }
}()

// THIS IGNORES APOSTROPHES!
func binarySearch(array: NSArray, var target: String, caseSensitive: Bool) -> Int? {
    var left = 0
    var right = array.count - 1
    target = caseSensitive ? target : target.lowercaseString
    
    while (left <= right) {
        let mid = (left + right) / 2
        let value = caseSensitive ? array[mid] as! String : (array[mid] as! String).lowercaseString
        let valueWithoutQuotes = value.stringByReplacingOccurrencesOfString("'", withString: "")
        
        let compareValue = value.compare(target)
        
        if valueWithoutQuotes == target {
            // this conditional is just to not always autocorrect with apostrophes
            if mid < array.count - 1 && (array[mid + 1] as! String) == target {
                return mid + 1
            }
            return mid
        }
        
        if compareValue == .OrderedDescending {
            right = mid - 1
        } else if compareValue == .OrderedAscending {
            left = mid + 1
        }
    }
    
    return nil
}

