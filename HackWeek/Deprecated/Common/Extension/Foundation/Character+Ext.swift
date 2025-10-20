//
//  Character+Ext.swift
//  AINote
//
//  Created by Martin on 2024/11/18.
//

import Foundation

extension Character {
    init?(englishCharacterIndex: Int, capture: Bool) {
        let firstCharacter: Character = capture ? "A" : "a"
        guard var value = firstCharacter.intValue else {
            return nil
        }
        value += englishCharacterIndex
        self = value.character
    }
    
    var intValue: Int? {
        guard let scalar = self.unicodeScalars.first else {
            return nil
        }
        return Int(scalar.value)
    }
}
