//
//  LanguageUtil.swift
//  SnapBoard -- Multi-line Text for Snapchat
//
//  Created by Grant Magdanz on 2/13/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation

// current supported languages
enum Language {
    case English
    case Arabic
    case Swedish
}

// Returns the current language of the phone. Defaults to English.
func getCurrentLanguage() -> Language {
    let lang = NSLocale.preferredLanguages()[0]
    if lang.lowercaseString.rangeOfString("ar") != nil {
        return Language.Arabic
    } else if lang.lowercaseString.rangeOfString("sv") != nil {
        return Language.Swedish
    } else {
        // just default to English
        return Language.English
    }
}

func deviceIsInArabic() -> Bool {
    return getCurrentLanguage() == Language.Arabic
}

func deviceIsInEnglish() -> Bool {
    return getCurrentLanguage() == Language.English
}