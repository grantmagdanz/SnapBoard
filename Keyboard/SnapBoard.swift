//
//  Snapboard.swift
//
//  Created by Grant Magdanz on 9/24/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

import UIKit

class Snapboard: KeyboardViewController {
    let CONTEXT_BEFORE_INSERTION_KEY = "contextBefore"
    let ATTEMPTED_CHARACTER_KEY = "attemptedCharacter"
    let AUTOWRAP_WAIT_TIME = 0.05
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        NSUserDefaults.standardUserDefaults()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func contextChanged() {
        self.setCapsIfNeeded()
        if let context = self.textDocumentProxy.documentContextBeforeInput {
            if context[context.endIndex.predecessor()] == " " {
                self.autoPeriodState = .FirstSpace
                return
            }
        }
        self.autoPeriodState = .NoSpace
    }
    
    override func keyPressed(key: Key) {
        let textDocumentProxy = self.textDocumentProxy
        let keyOutput = key.outputForCase(self.shiftState.uppercase())
        
        let contextBeforeTextInsertionOpt = textDocumentProxy.documentContextBeforeInput
        
        if key.type == .Return && contextBeforeTextInsertionOpt != nil && contextBeforeTextInsertionOpt!.characters.last == " " {
            self.textDocumentProxy.deleteBackward()
        }
        
        self.textDocumentProxy.insertText(keyOutput)
        
        if key.type == .Character || key.type == .SpecialCharacter || key.type == .Period || key.type == .Space {
            if let contextBeforeTextInsertion = contextBeforeTextInsertionOpt {
                
                // The Snapchat app itself is stopping extra characters from being added. Calling documentContextBeforeInput after a textInsert makes it appear that the character was inserted correctly even if it was not inserted at all (at least from the view of the Snapchat user). So in order to see if we need to autowrap, a brief timer is put onto the call to let Snapchat do its thing and then we test if the character was actually added.
               NSTimer.scheduledTimerWithTimeInterval(AUTOWRAP_WAIT_TIME, target: self, selector: "autoWrapIfNeeded:", userInfo: [CONTEXT_BEFORE_INSERTION_KEY: contextBeforeTextInsertion, ATTEMPTED_CHARACTER_KEY: keyOutput], repeats: false)
            }
        }
    }
    
    /* PRE: This method assumes a few things!
        1) timer.userInfo is a [String: String]
        2) timer.userInfo[CONTEXT_BEFORE_INSERTION_KEY] != nil
        3) timer.userInfo[ATTEMPTED_CHARACTER_KEY] != nil
    
        This will crash if any of those are violated
    
        This is kind of jenky and is tied to a scheduledTiemrWithTimeInterval call at the time of writing this. It tests if the previous character was infact inserted into the documentProxy and, if not, adds in a new line and the character.
    
        Used for autowrapping in Snapchat.
    */
    func autoWrapIfNeeded(timer: NSTimer) {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kWrapLines) {
            return
        }
        
        let userInfo = timer.userInfo as! [String: String]
        let contextBeforeTextInsertion = userInfo[CONTEXT_BEFORE_INSERTION_KEY]!
        
        if let contextAfterTextInsertion = self.textDocumentProxy.documentContextBeforeInput {
            if contextBeforeTextInsertion == contextAfterTextInsertion {
                // the character was not added. Add in a new line and the character.
                let typedCharacter = userInfo[ATTEMPTED_CHARACTER_KEY]!
                
                self.autoWrappedMidSentence = !isFirstWord()
                
                // if the previous character was a space, we just want to add in the new line and the character without wrapping a word
                var positionAdjustment = 0
                if contextBeforeTextInsertion.characters.last! != " " {
                    // we need to wrap a word!
                    let words = contextBeforeTextInsertion.characters.split{$0 == " "}.map(String.init)
                    let lastWord = words.last!
                    positionAdjustment = lastWord.characters.count
                } else {
                    // the space adds some issues at the end of lines, so let's just get rid of it
                    self.textDocumentProxy.deleteBackward()
                }
                
                setCapsIfNeeded()
                
                // reminder: positionAdjustment == 0 if the last character was a space
                self.textDocumentProxy.adjustTextPositionByCharacterOffset(-positionAdjustment)
                self.textDocumentProxy.insertText("\u{200B}\n")
                self.textDocumentProxy.adjustTextPositionByCharacterOffset(positionAdjustment)
                self.textDocumentProxy.insertText(typedCharacter)
                
                if typedCharacter == " " {
                    self.handleAutoPeriod(Key(.Space))
                }
            }
        }
    }
    
    func isFirstWord() -> Bool {
        if let context = self.textDocumentProxy.documentContextBeforeInput {
            let words = context.characters.split{$0 == " "}.map(String.init)
            if words.count > 1 {
                let previousWord: String
                if context.characters.last! != " " {
                    previousWord = words[words.count - 2]
                } else {
                    // this is the special case where the user is typing the first letter of a word so when we split on spaces we actually want the last index, not the second to last
                    previousWord = words[words.count - 1]
                }
                let charView = String(previousWord.characters.last!)
                return ".?!".rangeOfString(charView) != nil
            }
        }
        return true
    }
    
    override func createBanner() -> ExtraView? {
        return Banner(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
    }
}
