//
//  Token.swift
//  TestEditor
//
//  Created by poisson florent on 04/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

enum Token: String {
    case hash                   = "#"
    case colon                  = ":"
    case comma                  = ","
    case dot                    = "."
    case leftParenthesis        = "("
    case rightParenthesis       = ")"
    case leftCurlyBrace         = "{"
    case rightCurlyBrace        = "}"
    case onesComplement         = "~"
    case logicalNegation        = "!"
    case plus                   = "+"
    case minus                  = "-"
    case multiplication         = "*"
    case divide                 = "/"
    case remainder              = "%"
    case assignment             = "="
    case equal                  = "=="
    case notEqual               = "!="
    case lessThan               = "<"
    case greaterThan            = ">"
    case greaterThanOrEqualTo   = ">="
    case lessThanOrEqualTo      = "<="
    case logicalAND             = "&&"
    case logicalOR              = "||"
    case integer                // 999
    case real                   // 999.999
    case string                 // "text"
    case boolean                // true/false
    case identifier
    // Commands
    case importToken            = "import"
    case ifToken                = "if"
    case elseToken              = "else"
    case forToken               = "for"
    case inToken                = "in"
    case to                     // "to"
    case step                   // "step"
    case whileToken             = "while"
    case breakToken             = "break"
    case continueToken          = "continue"
    case funcToken              = "func"
    case funcReturnToken        = "->"
    case returnToken            = "return"
    case variable               = "var"
    case constant               = "const"
    case classToken             = "class"
    case staticToken            = "static"
    case superToken             = "super"
    case lf                     // Line feed \n
    case eof                    // End of file
    
    static let binaryOperatorTokens: Set<Token> = [
        .plus, .minus, .multiplication, .divide, .remainder, .assignment, .equal,
        .notEqual, .lessThan, .greaterThan, .greaterThanOrEqualTo, .lessThanOrEqualTo,
        .logicalAND, .logicalOR
    ]
    
    static let unaryOperatorTokens: Set<Token> = [
        .onesComplement, .logicalNegation, .plus, .minus
    ]
    
    static let reservedKeywords: Set<Token> = [
        .importToken, .ifToken, .elseToken, .forToken, .inToken, .to,
        .step, .whileToken, .breakToken, .continueToken, .funcToken, .returnToken,
        .variable, constant, classToken, .staticToken, .superToken
    ]
    
}
