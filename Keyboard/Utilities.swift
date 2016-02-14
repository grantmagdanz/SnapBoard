//
//  Utilities.swift
//  TastyImitationKeyboard
//
//  Created by Grant Baboulevitch on 10/22/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Foundation
import UIKit

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

