//
//  SpellChecker.swift
//  SnapBoard -- Multi-line Text for Snapchat
//
//  Created by Grant Magdanz on 12/29/15.
//  Copyright © 2015 Apple. All rights reserved.
//

/// Translation of [Peter Norvig's spell checker](http://norvig.com/spell-correct.html) into Swift.
/// Sample input corpus [here](http://norvig.com/big.txt)

import Foundation   // purely for IO, most things done with Swift.String

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
                return "\(left)\(snd)\(fst)\(drop2)"
            }
        }
        return ""
        }.filter { !$0.isEmpty }
    
    let alphabet = "abcdefghijklmnopqrstuvwxyz"
    
    let replaces = splits.flatMap { left, right in
        alphabet.characters.map { "\(left)\($0)\(right.characters.dropFirst())" }
    }
    
    let inserts = splits.flatMap { left, right in
        alphabet.characters.map{"\(left)\($0)\(right)" }
    }
    
    return Set(deletes + transposes + replaces + inserts)
}


struct SpellChecker {
    
    var knownWords: [String:Int] = [:]
    
    mutating func train(word: String) {
        knownWords[word] = knownWords[word]?.successor() ?? 1
    }
    
    init?(contentsOfFile file: String) {
        var words: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("frequencies", ofType: "plist") {
            words = NSDictionary(contentsOfFile: path)
        }
        do {
            let text = try String(contentsOfFile: file, encoding: NSUTF8StringEncoding).lowercaseString
            let words = text.unicodeScalars.split{ !("a"..."z").contains($0) }.map { String($0) }
            for word in words {
                self.train(word)
            }
        }
        catch {
            return nil
        }
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
        let s = Set(words.filter{ self.knownWords.indexForKey($0) != nil })
        return s.isEmpty ? nil : s
    }
    
    func correct(word: String) -> String {
        let candidates = known([word]) ?? known(edits(word)) ?? knownEdits2(word)
        
        return (candidates ?? []).reduce(word) {
            (knownWords[$0] ?? 1) < (knownWords[$1] ?? 1) ? $1 : $0
        }
    }
}


// main()
/*let filename = "big.txt"
try String(contentsOfFile: filename, encoding: NSUTF8StringEncoding).lowercaseString

if let checker = SpellChecker(contentsOfFile: filename) {
    
    print("Type word to check and hit enter")
    while let word = NSString(data: NSFileHandle.fileHandleWithStandardInput().availableData,
        encoding: NSUTF8StringEncoding) as? String
        where word.characters.last == "\n"
    {
        let word = String(word.characters.dropLast())
        let checked = checker.correct(word)
        
        if word == checked {
            print("\(word) unchanged")
        }
        else {
            print("\(word) -> \(checked)")
        }
    }
    
}
else {
    print("Usage: (Process.arguments[0]) <corpus_filename>")
}
*/
