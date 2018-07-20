//
//  Script.swift
//  TestEditor
//
//  Created by poisson florent on 05/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

struct Script {

    let characters: Array<Character>
    let lines: [NSRange]
    
    var string: String {
       return String(characters)
    }
    
    init(string: String) {
        self.characters = Array(string)
        self.lines = Script.computeLines(in: self.characters)
    }
    
    private static func computeLines(in characters: Array<Character>) -> [NSRange] {
        var lines = [NSRange]()

        var lineLocation = 0
        var lineLength = 0
        
        for character in characters {
            lineLength += 1
            if character == "\n" {
                // Add line feed
                lines.append(NSRange(location: lineLocation, length: lineLength))
                lineLocation += lineLength
                lineLength = 0
            }
        }
        
        // Add last line
        lines.append(NSRange(location: lineLocation, length: lineLength))
        
//        print("lines = \(lines)")
        return lines
    }
    
    func getLineIndex(forCursorPosition cursorPosition: Int) -> Int {
        if cursorPosition >= characters.count {
            return lines.count - 1
        }
        
        for (index, line) in lines.enumerated() {
            if cursorPosition >= line.location
                && cursorPosition < NSMaxRange(line) {
                return index
            }
        }
        return 0
    }
    
}
