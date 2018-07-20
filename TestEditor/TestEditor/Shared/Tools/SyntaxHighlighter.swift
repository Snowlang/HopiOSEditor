//
//  SyntaxHighlighter.swift
//  TestEditor
//
//  Created by poisson florent on 04/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

struct SyntaxHighlighter {

    static func colorizeScript(script: String, theme: Theme) throws -> NSAttributedString {

        let lexer = Lexer(script: script)
        let whollyCommentedSource = script.withFont(theme.font).withTextColor(theme.commentColor)
        let colorizedScript = NSMutableAttributedString(attributedString: whollyCommentedSource)
        var previousTokenLocation: Int = 0
        var previousTokenLength: Int = 0
        var currentToken: Token!
        var tokensHistory = [Token]()

        // Helper functions
        func getNextToken() throws {
            currentToken = try lexer.getNextToken()
        }
        
        func colorize(color: UIColor, location: Int, lenght: Int) {
            colorizedScript.setAttributes([
                .font: theme.font,
                .foregroundColor : color
                ], range: NSRange(location: location, length: lenght))
        }

        try getNextToken()

        while currentToken != .eof {

            var color = theme.textColor
            var tokenLength = currentToken.rawValue.count
            
            if Token.reservedKeywords.contains(currentToken) {
                color = theme.keywordsColor
                
            } else if Token.unaryOperatorTokens.contains(currentToken) ||
                Token.binaryOperatorTokens.contains(currentToken) {
                color = theme.operatorColor

            } else if currentToken == .integer,
                let integer = lexer.currentTokenValue as? Int {
                color = theme.numberColor
                tokenLength = String(integer).count

            } else if currentToken == .real,
                let real = lexer.currentTokenValue as? Double {
                color = theme.numberColor
                tokenLength = String(real).count

            } else if currentToken == .string,
                let string = lexer.currentTokenValue as? String {
                color = theme.stringColor
                var quotesCount = 1
                if let character = lexer.getChar(at: lexer.getCurrentPosition() - 1),
                    character == "\"",
                    !string.isEmpty {
                    quotesCount = 2
                }
                
                tokenLength = string.count + quotesCount
                
            } else if currentToken == .boolean {
                color = theme.numberColor

            } else if currentToken == .identifier,
                let string = lexer.currentTokenValue as? String {
                
                tokenLength = string.count
                
                if string == "self" {
                    color = theme.keywordsColor
                
                } else if let previousToken = tokensHistory.last {
                    if previousToken == .funcToken {
                        color = theme.functionDeclarationColor

                    } else if previousToken == .dot {
                        color = theme.accessedMembers
                        
                    } else if previousToken == .colon {
                        color = theme.typeColor
                    }
                }
            } else if currentToken == .dot {
                
            } else if currentToken == .leftParenthesis,
                let previousToken = tokensHistory.last {
                if previousToken == .identifier {
                    // Et il n'y a pas de token func en position n-2
                    if tokensHistory.count < 2 || tokensHistory[0] != .funcToken {
                        colorize(color: theme.functionCallColor,
                                 location: previousTokenLocation,
                                 lenght: previousTokenLength)
                    }
                }
            } else if currentToken == .lf {
                tokenLength = 0
            }
            
            let tokenLocation = lexer.nextCharIndex - tokenLength

            colorize(color: color, location: tokenLocation, lenght: tokenLength)
            
            previousTokenLocation = tokenLocation
            previousTokenLength = tokenLength
            tokensHistory.append(currentToken)
            if tokensHistory.count > 2 {
                tokensHistory.removeFirst()
            }
            
            try getNextToken()
            
//            print(tokensHistory)
        }
        
        return colorizedScript
    }
    
}
