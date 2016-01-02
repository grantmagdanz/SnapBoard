//
//  SpellChecker.swift
//  SnapBoard -- Multi-line Text for Snapchat
//
//  Created by Grant Magdanz on 12/29/15.
//  Copyright © 2015 Apple. All rights reserved.
//

/// Translation of [Peter Norvig's spell checker](http://norvig.com/spell-correct.html) into Swift.
/// Sample input corpus [here](http://norvig.com/big.txt)

import Foundation

struct SpellChecker {
    // the point at when the concurrent edits2 finds solutions iteratively
    let ITERATIVE_THRESHOLD = 10
    
    var wordFrequencies: NSDictionary
    var words: NSArray
    
    // the spell checker will be passing in strings in all lowercase, so these keys need to be lowercase as well!
    var directCorrections = NSDictionary(dictionary: [
        "i": "I",
        "lets": "let's",
        "snapboard": "SnapBoard"
        ])

    
    init?(frequenciesFile: String, wordListFile: String) {
        if let frequencies = NSDictionary(contentsOfFile: frequenciesFile) {
            if let dictionary = NSArray(contentsOfFile: wordListFile) {
                wordFrequencies = frequencies
                words = dictionary
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /// Given a word, produce a set of possible alternatives with
    /// letters transposed, deleted, replaced or rogue characters inserted
    func edits(word: String) -> Set<String> {
        if word.isEmpty { return [] }
        
        let splits = word.characters.indices.map {
            (word[word.startIndex..<$0], word[$0..<word.endIndex])
        }
        
        let deletes = splits.map { $0.0 + String($0.1.characters.dropFirst()) }
        
        let transposes: [String] = splits.map{ left, right in
            if let fst = right.characters.first {
                let drop1 = right.characters.dropFirst()
                if let snd = drop1.first {
                    let drop2 = drop1.dropFirst()
                    return "\(left)" + String(snd) + String(fst) + String(drop2)
                }
            }
            return ""
            }.filter { !$0.isEmpty }
        
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        
        let replaces = splits.flatMap { left, right in
            alphabet.characters.map { "\(left)" + String($0) + String(right.characters.dropFirst())}
        }
        
        let inserts = splits.flatMap { left, right in
            alphabet.characters.map{"\(left)\($0)\(right)" }
        }
        let toReturn = Set(deletes + transposes + replaces + inserts)
        return toReturn
    }

    
    func knownEdits2(word: String) -> Set<String>? {
        let possibleEdits = Array(edits(word))
        
        // setup concurrency
        let group = dispatch_group_create()
        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        
        let numberOfThreads = Int(ceil(Double(possibleEdits.count) / Double(ITERATIVE_THRESHOLD)))
        
        // we need an array of Sets to make sure that we don't have a race condition
        var knownEditsOfEachThread: [Set<String>?] = [Set<String>?](count: numberOfThreads, repeatedValue: nil)
        
        // dispatch threads
        for i in 0..<numberOfThreads {
            dispatch_group_async(group, queue) {
                let base = i * self.ITERATIVE_THRESHOLD
                var knownEditsOfThisThread = Set<String>()
                
                // this takes care of the last iteration where we may not want to go ITERATIVE_THRESHOLD times
                let end = min(base + self.ITERATIVE_THRESHOLD, possibleEdits.count)
                for curr in base ..< end {
                    if let k = self.known(self.edits(possibleEdits[curr])) {
                        knownEditsOfThisThread.unionInPlace(k)
                    }
                }
                knownEditsOfEachThread[i] = knownEditsOfThisThread
            }
        }
        
        var knownEdits: Set<String> = []
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        for edits in knownEditsOfEachThread {
            if edits != nil {
                knownEdits.unionInPlace(edits!)
            }
        }
        print(knownEdits.count)
        return knownEdits.isEmpty ? nil : knownEdits
    }
    
    func known<S: SequenceType where S.Generator.Element == String>(words: S) -> Set<String>? {
        let s = Set(words.filter{ self.wordFrequencies.valueForKey($0) != nil })
        return s.isEmpty ? nil : s
    }
    
    // literal being whether the string should be taken literally (i.e. do not try to auto capitalize it) or not
    func correct(word: String) -> (correctWord: String, literal: Bool) {
        // Probably shouldn't try to autocorrect a number huh?
        if let _ = Double(word) {
            return (word, true)
        }
        
        // Check if there is a direct edit
        if let directCorrection = directCorrections.valueForKey(word.lowercaseString) as? String {
            if directCorrection.capitalizedString == directCorrection {
                return (directCorrection, true)
            } else {
                return (directCorrection, false)
            }
        }
        
        // Is this a word already? Let's find out...
        if let index = binarySearch(words, target: word, caseSensitive: false) {
            let foundWord = words[index] as! String
            if foundWord.capitalizedString == foundWord || foundWord.uppercaseString == foundWord {
                return (foundWord, true)
            } else {
                return (foundWord, false)
            }
        }
        
        // We're just going to have to guess then...
        let candidates = known([word]) ?? known(edits(word)) //?? knownEdits2(word)
        let result = (candidates ?? []).reduce(word) {
            let val1 = (wordFrequencies.valueForKey($0) ?? Int.max) as! Int
            let val2 = (wordFrequencies.valueForKey($1) ?? Int.max) as! Int
            return val1 <= val2 ? $0 : $1
        }
        return (result, false)
    }
}