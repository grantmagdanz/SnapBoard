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
    
    var wordFrequencies: NSDictionary
    var words: NSArray
    var literalCorrections = NSDictionary(dictionary: ["i": "I"])
    
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
        var known_edits: Set<String> = []
        let possibleEdits = edits(word)
        for edit in possibleEdits {
            if let k = known(edits(edit)) {
                known_edits.unionInPlace(k)
            }
        }
        return known_edits.isEmpty ? nil : known_edits
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
        if let literalCorrection = literalCorrections.valueForKey(word) {
            return (literalCorrection as! String, true)
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