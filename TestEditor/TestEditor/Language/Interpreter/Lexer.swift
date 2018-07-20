//
//  Lexer.swift
//  TestLexer
//
//  Created by poisson florent on 26/05/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation


enum LexerError: Error {
    case unknownError
    case illegalContent(position: Int)
}

class Lexer {
    
    private var chars: [Character]!
    private(set) var nextCharIndex: Int = 0
    private var lineIndex: Int = 0
    private var currentChar: Character! {
        if nextCharIndex < chars.count {
            return chars[nextCharIndex]
        }
        return nil
    }
    var currentTokenValue: Any?
    
    init(script: String) {
        chars = Array(script)
    }
    
    init?(with url: URL) {
        let program = self.loadProgram(from: url)
        if program == nil { return nil }
        chars = Array(program!)
    }
    
    func getCurrentPosition() -> Int {
        return nextCharIndex
    }
    
    func getNextChar() {
        nextCharIndex += 1
    }
    
    func getChar(at index: Int) -> Character? {
        if index < 0 { return nil }
        if index > chars.count - 1 { return nil }
        return chars[index]
    }
    
    func getNextToken() throws -> Token {
        if currentTokenValue != nil {
            currentTokenValue = nil
        }
        
        if currentChar == nil {
            return Token.eof
        }
        
        // Consume white space
        // (i.e. space, horizontal tab (TAB), vertical tab (VT), feed (FF), carriage return (CR))
        while isWhiteSpace(currentChar) {
            getNextChar()
            if currentChar == nil {
                return Token.eof
            }
        }
        
        // Consume line feeds
        while currentChar == "\n" {
            getNextChar()   // Consume '\n'
            lineIndex += 1
            if currentChar != "\n" {
                return Token.lf
            }
        }

        // Consume divide
        if currentChar == "/" {
            // Consume character
            getNextChar()
            
            if currentChar != nil {
                if currentChar == "/" {
                    getNextChar()
                    // Consume // comment up to the end of line
                    while currentChar != nil && currentChar != "\n" {
                        getNextChar()
                    }
                    return try getNextToken()
                } else if currentChar == "*" {
                    getNextChar()
                    // Consume /* */ comment
                    while true {
                        if currentChar == nil {
                            return Token.eof
                        }
                        
                        if currentChar == "\n" {
                            lineIndex += 1
                        }
                        
                        if currentChar == "*" {
                            getNextChar()
                            if currentChar != nil && currentChar == "/" {
                                getNextChar()
                                return try getNextToken()
                            }
                        } else {
                            getNextChar()
                        }
                    }
                }
            }
            
            return Token.divide
        }
        
        // Consume hash
        if currentChar == "#" {
            getNextChar()
            return .hash
        }
        
        // Consume colon
        if currentChar == ":" {
            getNextChar()
            return .colon
        }
        
        // Consume comma
        if currentChar == "," {
            getNextChar()
            return .comma
        }

        // Consume dot
        if currentChar == "." {
            getNextChar()
            return .dot
        }

        // Consume left curly brace
        if currentChar == "{" {
            getNextChar()
            return .leftCurlyBrace
        }
        
        // Consume right curly brace
        if currentChar == "}" {
            getNextChar()
            return .rightCurlyBrace
        }
        
        // Consume left parenthesis
        if currentChar == "(" {
            getNextChar()
            return .leftParenthesis
        }
        
        // Consume right parenthesis
        if currentChar == ")" {
            getNextChar()
            return .rightParenthesis
        }
        
        // Consume ones' complement
        if currentChar == "~" {
            getNextChar()
            return .onesComplement
        }
        
        // Consume logical negation
        if currentChar == "!" {
            getNextChar()
            
            // Consume not equal
            if currentChar != nil && currentChar == "=" {
                getNextChar()
                return .notEqual
            }
            
            return .logicalNegation
        }
        
        // Consume plus
        if currentChar == "+" {
            getNextChar()
            return .plus
        }
        
        // Consume minus
        if currentChar == "-" {
            getNextChar()
            
            if currentChar != nil && currentChar == ">" {
                getNextChar()  // Consume function return token '->'
                return .funcReturnToken
            }
            
            return .minus
        }
        
        // Consume multiplication
        if currentChar == "*" {
            getNextChar()
            return .multiplication
        }
        
        // Consume remainder
        if currentChar == "%" {
            getNextChar()
            return .remainder
        }

        // Consume assignment
        if currentChar == "=" {
            getNextChar()
            
            if currentChar != nil && currentChar == "=" {
                getNextChar() // Consume equal '=='
                return .equal
            }
            
            return .assignment
        }
        
        // Consume less than
        if currentChar == "<" {
            getNextChar()
            
            // Consume less than or equal to
            if currentChar != nil && currentChar == "=" {
                getNextChar()
                return .lessThanOrEqualTo
            }
            
            return .lessThan
        }
        
        // Consume greater than
        if currentChar == ">" {
            getNextChar()
            
            // Consume greater than or equalTo
            if currentChar != nil && currentChar == "=" {
                getNextChar()
                return .greaterThanOrEqualTo
            }
            
            return .greaterThan
        }
        
        // Consume logical AND
        if currentChar == "&" {
            getNextChar()
            
            // Consume logical AND
            if currentChar != nil && currentChar == "&" {
                getNextChar()
                return .logicalAND
            }
            
            throw LexerError.illegalContent(position: nextCharIndex - 1)
        }
        
        // Consume logical OR
        if currentChar == "|" {
            getNextChar()
            
            // Consume logical OR
            if currentChar != nil && currentChar == "|" {
                getNextChar()
                return .logicalOR
            }
            
            throw LexerError.illegalContent(position: nextCharIndex - 1)
        }
        
        // Consume identifier
        if isAlpha(currentChar) {
            var buffer = String(currentChar)
            getNextChar()
            
            while currentChar != nil && isAlphanumeric(currentChar) {
                buffer.append(currentChar)
                getNextChar()
            }
            
            // Reserved keywords
            if let token = Token(rawValue: buffer),
                Token.reservedKeywords.contains(token) {
                return token
            }
            
            // Values or identifier
            switch buffer {
            case "true":
                currentTokenValue = true
                return .boolean
            case "false":
                currentTokenValue = false
                return .boolean
            default:
                currentTokenValue = buffer
                return Token.identifier
            }
        }
        
        if isNumeric(currentChar) {
            var buffer = String(currentChar)
            var hasDecimal = false
            getNextChar()
            
            while currentChar != nil && (isNumeric(currentChar) || (!hasDecimal && currentChar == ".")) {
                buffer.append(currentChar)
                if currentChar == "." {
                    hasDecimal = true
                }
                getNextChar()
            }
            
            if hasDecimal {
                currentTokenValue = Double(buffer)!
                return .real
            }
            
            currentTokenValue = Int(buffer)!
            return .integer
        }
        
        // Consume string literal
        if currentChar == "\"" {
            getNextChar() // Consume first "

            var buffer = ""
            while currentChar != nil {
                if currentChar == "\\" {
                    buffer.append(currentChar)
                    getNextChar()
                    
                    if currentChar != nil {
                        // Consume escaped character
                        buffer.append(currentChar)
                        getNextChar()
                    }
                } else if currentChar == "\"" {
                    getNextChar() // Consume last "
                    break
                } else {
                    buffer.append(currentChar)
                    getNextChar()
                }
            }
            
            currentTokenValue = buffer
            return .string
        }
        
        throw LexerError.unknownError
    }
    
    // MARK: Helpers
    
    private func loadProgram(from url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch let error {
            print("Error: program file loading failed with error: \(error)")
        }
        return nil
    }

    static private let whiteSpaces = [" ", "\t", "\r"]
    static private let alphas = "abcdefghijklmnopqrstuvwxyz"
    static private let numerics = Array("0123456789")
    static private let lowercasedAlphas = Array(alphas)
    static private let uppercasedAlphas = Array(alphas.uppercased())
    
    private func isWhiteSpace(_ character: Character) -> Bool {
        return Lexer.whiteSpaces.contains(String(currentChar))
    }
    
    private func isAlpha(_ character: Character) -> Bool {
        return Lexer.lowercasedAlphas.contains(character) ||
            Lexer.uppercasedAlphas.contains(character)
    }
    
    private func isNumeric(_ character: Character) -> Bool {
        return Lexer.numerics.contains(character)
    }
    
    private func isAlphanumeric(_ character: Character) -> Bool {
        return isAlpha(character) || isNumeric(character)
    }

}

