//
//  Parser.swift
//  TestLexer
//
//  Created by poisson florent on 29/05/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

private let binOpPrecedences: [Token : Int] = [
    .assignment: 10,
    .logicalAND: 20,
    .logicalOR: 20,
    .equal: 30,
    .notEqual: 30,
    .lessThan: 40,
    .greaterThan: 40,
    .greaterThanOrEqualTo: 40,
    .lessThanOrEqualTo: 40,
    .plus: 50,
    .minus: 50,
    .multiplication: 60,
    .divide: 60,
    .remainder: 60,
    .dot: 70
]

enum ParserError: Error {
    case expressionError
    case prototypeError
}

class Parser {

    private let lexer: Lexer
    private var currentToken: Token!
    
    init(with lexer: Lexer) {
        self.lexer = lexer
    }
    
    private func getNextToken() throws {
        currentToken = try lexer.getNextToken()
        if let currentToken = currentToken {
            print("------------------------------------")
            print("--> currentToken = \(currentToken)")
            let currentPosition = lexer.getCurrentPosition()
            print("--> charIndex: \(currentPosition)")
        } else {
            print("--> currentToken is empty")
        }
    }
    
    func getCurrentTokenPrecedence() -> Int {
        guard let currentToken = currentToken,
            let precedence = binOpPrecedences[currentToken] else {
                return -1
        }
        
        return precedence
    }
    
    func parseProgram() throws -> Program? {
        try getNextToken()
        var statements = [Evaluable]()
        while currentToken != .eof {
            if let statement = try parseStatement() {
                statements.append(statement)
            }
        }
        if statements.count > 0 {
            return Program(block: BlockStmt(statements: statements))
        }
        
        return nil
    }
    
    // MARK: - Statements parsing
    
    private func parseStatement() throws -> Evaluable? {
        
        while currentToken == .lf {
            try getNextToken() // Consume isolated line feed
        }
        
        if currentToken == .importToken {
            return try parseImportStatement()
        }
        
        if currentToken == .funcToken {
            return try parseFunctionStatement()
        }
        
        if currentToken == .returnToken {
            return try parseReturnStatement()
        }

        if currentToken == .breakToken {
            return try parseBreakStatement()
        }

        if currentToken == .continueToken {
            return try parseContinueStatement()
        }

        if currentToken == .ifToken {
            return try parseIfStatement()
        }
        
        if currentToken == .forToken {
            return try parseForStatement()
        }
        
        if currentToken == .whileToken {
            return try parseWhileStatement()
        }
        
        if currentToken == .variable {
            return try parseVariableDeclarationStatement()
        }
        
        if currentToken == .constant {
            return try parseConstantDeclarationStatement()
        }
        
        if currentToken == .classToken {
            return try parseClassDeclarationStatement()
        }
        
        return try parseExpressionStatement()
    }
    
    /**
 
     "import" <i> "\n"
     
    */
    private func parseImportStatement() throws -> Evaluable? {
        guard currentToken == .importToken else {
            // Import token is awaited
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'import'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume identifier
        
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume line feed
        
        return ImportStmt(name: name)
    }
    
    /**
     
     "func" <id> "(" <argument>* ")" "=>" <id> "{" <statement>* "}" "\n"
     
    */
    private func parseFunctionStatement() throws -> Evaluable? {
        if currentToken != .funcToken {
            // Function token is awaited
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'func'

        let prototype = try parseFunctionPrototype()
        let block = try parseBlock()
        
        // Expected line feed
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume line feed
        
        return FunctionDeclarationStmt(prototype: prototype,
                                       block: block)
    }
    
    /**
     
        <id> "(" <argument>* ")" "=>" <id>
     
    */
    private func parseFunctionPrototype() throws -> FunctionDeclarationPrototype {
        if currentToken == .identifier,
            let name = lexer.currentTokenValue as? String {
            
            try getNextToken() // Consume identifier
            
            // Check if identifier is not a reserved keyword
            if let token = Token(rawValue: name),
                Token.reservedKeywords.contains(token) {
                throw ParserError.expressionError
            }
            
            if currentToken == .leftParenthesis {
                
                try getNextToken() // Consume '('
                
                let arguments = try parseFunctionArguments()

                if currentToken == .rightParenthesis {
                    
                    try getNextToken() // Consume ')'

                    var typeExpr: Evaluable?

                    // Process optional returned type
                    if currentToken == .funcReturnToken {
                        
                        try getNextToken() // Consume '->'

                        typeExpr = try parseTypeExpression()
                        if typeExpr == nil {
                            throw ParserError.expressionError
                        }
                    }
                    
                    return FunctionDeclarationPrototype(name: name,
                                                        arguments: arguments,
                                                        typeExpr: typeExpr)
                } else {
                    throw ParserError.prototypeError
                }
            } else {
                throw ParserError.prototypeError
            }
        } else {
            throw ParserError.prototypeError
        }
    }
    
    private func parseFunctionArgument(isAnonymous: Bool = false) throws -> FunctionDeclarationArgument? {
        if currentToken == .hash {
            // Anonymous parameter
            try getNextToken() // Consume #
            
            return try parseFunctionArgument(isAnonymous: true)

        } else if currentToken == .identifier,
            let name = lexer.currentTokenValue as? String {
            
            try getNextToken() // Consume argument name
            
            if currentToken == .colon {
                
                try getNextToken() // Consume colon

                guard let typeExpr = try parseTypeExpression() else {
                    throw ParserError.prototypeError
                }

                return FunctionDeclarationArgument(name: name,
                                                   typeExpr: typeExpr,
                                                   isAnonymous: isAnonymous)
            } else {
                throw ParserError.prototypeError
            }
        }

        return nil
    }
    
    private func parseFunctionArguments() throws -> [FunctionDeclarationArgument]? {
        var arguments = [FunctionDeclarationArgument]()
        
        while true {
            if let argument = try parseFunctionArgument() {
                arguments.append(argument)
                
                if currentToken == .comma {
                    try getNextToken() // Consume comma separator
                }
            } else {
                // End of arguments
                break
            }
        }
        
        if arguments.count > 0 {
            return arguments
        }

        return nil
    }
    
    /**
     "init" ["(" <parameter>* ")"] "{" <block> "}"
    */
//    private func parseInitializerDeclarationStatement() throws -> Evaluable? {
//        guard currentToken == .initToken else {
//            throw ParserError.expressionError
//        }
//
//        try getNextToken() // Consume 'init'
//
//        var arguments: [Prototype.Argument]!
//
//        if currentToken == .leftParenthesis {
//
//            try getNextToken() // Consume '('
//
//            arguments = try parseFunctionArguments()
//
//            guard currentToken == .rightParenthesis else {
//                throw ParserError.prototypeError
//            }
//
//            try getNextToken() // Consume ')'
//        }
//
//        let block = try parseBlock()
//
//        // Expected line feed
//        guard currentToken == .lf else {
//            throw ParserError.expressionError
//        }
//
//        let prototype = Prototype(name: Token.initToken.rawValue,
//                                  arguments: arguments,
//                                  type: .void)
//
//        return FunctionDeclarationStmt(prototype: prototype,
//                                       block: block)
//    }

//    /**
//     "deinit" "{" <block> "}"
//     */
//    private func parseDeinitializerDeclarationStatement() throws -> Evaluable? {
//        guard currentToken == .deinitToken else {
//            throw ParserError.expressionError
//        }
//        
//        try getNextToken() // Consume 'deinit'
//
//        if let block = try parseBlock() {
//            guard currentToken == .lf else {
//                throw ParserError.expressionError
//            }
//            
//            try getNextToken() // Consume line feed
//            
//            let prototype = Prototype(name: Token.deinitToken.rawValue,
//                                      arguments: nil,
//                                      type: .void)
//            
//            return FunctionDeclarationStmt(prototype: prototype,
//                                           block: block)
//        }
//        
//        return nil
//    }
    
    private func parseBlock() throws -> BlockStmt? {
        guard currentToken == .leftCurlyBrace else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume '{'
        
        var statements = [Evaluable]()
        var noAnymoreStatement = false
        while true {
            if currentToken == .eof {
                throw ParserError.expressionError
            }
            
            if currentToken == .rightCurlyBrace {
                break
            }

            if noAnymoreStatement {
                throw ParserError.expressionError
            }
            
            if let statement = try parseStatement() {
                statements.append(statement)
            } else {
                noAnymoreStatement = true
            }
        }
        
        try getNextToken() // Consume '}'
        
        if statements.count > 0 {
            return BlockStmt(statements: statements)
        }
        
        return nil
    }

    
    /**
     "if" <expression> "{" <block> "}" ["else" "{" <block> "}"] "\n"
    */
    private func parseIfStatement() throws -> Evaluable? {
        guard currentToken == .ifToken else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'if'

        guard let conditionExpr = try parseExpression() else {
            throw ParserError.expressionError
        }

        var thenBlock: BlockStmt!
        var elseBlock: BlockStmt!
        
        var isThenStmtWithBrakets = false
        
        if currentToken == .leftCurlyBrace {
            
            isThenStmtWithBrakets = true
            
            thenBlock = try parseBlock()

        } else {
            throw ParserError.expressionError
        }

        if currentToken == .elseToken {
            
            try getNextToken() // Consume 'else'
            
            if currentToken == .leftCurlyBrace {
                
                elseBlock = try parseBlock()
                
                // Line feed is expected
                guard currentToken == .lf else {
                    throw ParserError.expressionError
                }
                
                try getNextToken() // Consume line feed
                
            } else if currentToken == .ifToken,
                let ifStatement = try parseIfStatement() {

                elseBlock = BlockStmt(statements: [ifStatement])
                
            } else {
                throw ParserError.expressionError
            }
        } else if isThenStmtWithBrakets {
            // Line feed is expected
            guard currentToken == .lf else {
                throw ParserError.expressionError
            }
            
            try getNextToken() // Consume line feed
        }
                
        return IfStmt(conditionExpression: conditionExpr, thenBlock: thenBlock, elseBlock: elseBlock)
    }

    /**
        "for" <id> "in" <expression> "to" <expression> ["step" <expression>] "{" <block> "}" "\n"
    */
    private func parseForStatement() throws -> Evaluable? {
        guard currentToken == .forToken else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'for'

        guard currentToken == .identifier,
            let indexName = lexer.currentTokenValue as? String else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume index identifier
        
        guard currentToken == .inToken else {
            throw ParserError.expressionError
        }

        try getNextToken() // Consume 'in'

        guard let startExpression = try parseExpression() else {
            throw ParserError.expressionError
        }
        
        guard currentToken == .to else {
            throw ParserError.expressionError
        }

        try getNextToken() // Consume 'to'

        guard let endExpression = try parseExpression() else {
            throw ParserError.expressionError
        }
        
        var stepExpression: Evaluable?
        
        if currentToken == .step {
            
            try getNextToken() // Consume 'step'
            
            stepExpression = try parseExpression()
            
            if stepExpression == nil {
                throw ParserError.expressionError
            }
        }

        let block = try parseBlock()

        guard currentToken == .lf else {
            throw ParserError.expressionError
        }

        try getNextToken() // Consume line feed

        if block != nil {
            return ForStmt(indexName: indexName,
                           startExpression: startExpression,
                           endExpression: endExpression,
                           stepExpression: stepExpression,
                           block: block!)
        }
        
        // No for loop body
        // => no needed to register a for loop
        return nil
    }

    /**
        "while" <expression> "{" <block> "}" "\n"
    */
    private func parseWhileStatement() throws -> Evaluable? {
        guard currentToken == .whileToken else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'while'
        
        guard let conditionExpression = try parseExpression() else {
            throw ParserError.expressionError
        }
        
        let block = try parseBlock()
        
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume line feed
        
        if block != nil {
            return WhileStmt(conditionExpression: conditionExpression, block: block!)
        }
        
        // No while loop body
        // => no needed to register a while loop
        return nil
    }
    
    /**
     
     "return" <expression optional> "\n"
     
    */
    private func parseReturnStatement() throws -> Evaluable? {
        guard currentToken == .returnToken else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'return'
        
        let result = try parseExpression()

        // Expected line feed
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume line feed
        
        return ReturnStmt(result: result)
    }
    
    /**
     
     "break" "\n"
     
     */
    private func parseBreakStatement() throws -> Evaluable? {
        guard currentToken == .breakToken else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'break'
        
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume line feed
        
        return BreakStmt()
    }
    
    /**
     
     "continue" "\n"
     
     */
    private func parseContinueStatement() throws -> Evaluable? {
        guard currentToken == .continueToken else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'continue'
        
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume line feed
        
        return ContinueStmt()
    }
    
    /**
     
     "const" <id> ":" <id> "=" <expression> "\n"
     
     */
    private func parseConstantDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .constant else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'const'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume constant identifier

        // Check if identifier is not a reserved keyword
        if let token = Token(rawValue: name),
            Token.reservedKeywords.contains(token) {
            throw ParserError.expressionError
        }

        // Type declaration is optional for constant declaration
        var typeExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            typeExpr = try parseTypeExpression()
            if typeExpr == nil {
                throw ParserError.expressionError
            }
        }

        // Parse assignment
        guard currentToken == .assignment else {
            throw ParserError.expressionError
        }

        try getNextToken() // Consume '='

        guard let expression = try parseExpression() else {
            throw ParserError.expressionError
        }
        
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }

        try getNextToken() // Consume '\n'

        return VariableDeclarationStmt(name: name,
                                       typeExpr: typeExpr,
                                       isConstant: true,
                                       isPrivate: false,
                                       expr: expression)
    }

    /**
     
     "var" <id> ":" <id> ["=" <expression>] "\n"
     
    */
    private func parseVariableDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .variable else {
            throw ParserError.expressionError
        }

        try getNextToken() // Consume 'var'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
                throw ParserError.expressionError
        }
        
        try getNextToken() // Consume constant identifier
        
        // Check if identifier is not a reserved keyword
        if let token = Token(rawValue: name),
            Token.reservedKeywords.contains(token) {
            throw ParserError.expressionError
        }
        
        // Type declaration can be optional for variable declaration
        // if assigned expression is filled.
        var typeExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            typeExpr = try parseTypeExpression()
            if typeExpr == nil {
                throw ParserError.expressionError
            }
        }

        // Parse optinal assignment
        var expression: Evaluable?

        if currentToken == .assignment {
            
            try getNextToken() // Consume '='

            expression = try parseExpression()
            
            if expression == nil {
                throw ParserError.expressionError
            }
        }
        
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume '\n'
        
        return VariableDeclarationStmt(name: name,
                                       typeExpr: typeExpr,
                                       isConstant: false,
                                       isPrivate: false,
                                       expr: expression)
    }
    
    /**
     <identifier>.(...)
     */
    private func parseTypeExpression() throws -> Evaluable? {
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
                return nil
        }
        
        try getNextToken() // Consume lhs identifier
        
        var lhs: Evaluable = IdentifierExpr(name: name)
        
        while true {
            if currentToken != .dot {
                return lhs
            }
            
            // Okay, we know this is a dot binop.
            try getNextToken() // eat binop
            
            // Parse next identifier
            guard currentToken == .identifier,
                let name = lexer.currentTokenValue as? String else {
                    return nil
            }
            
            try getNextToken() // Consume rhs identifier
            
            // Merge LHS/RHS.
            lhs = BinaryOperatorExpr(binOp: .dot, lhs: lhs, rhs: IdentifierExpr(name: name))
        }
    }
    
    private func parseExpressionStatement() throws -> Evaluable? {
        guard let expression = try parseExpression() else {
            return nil
        }
        
        guard currentToken == .lf else {
            // error: consecutive statements on a line are not allowed
            throw ParserError.expressionError
        }
        
        return ExpressionStmt(expr: expression)
    }
    
    /**
     "class" <id> "{" <statement>* "}" "\n"
    */
    private func parseClassDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .classToken else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume 'class'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
            throw ParserError.expressionError
        }

        try getNextToken() // Consume class identifier
        
        var superclassExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            superclassExpr = try parseTypeExpression()
            if superclassExpr == nil {
                throw ParserError.expressionError
            }
        }
        
        guard currentToken == .leftCurlyBrace else {
            throw ParserError.expressionError
        }

        try getNextToken() // Consume '{'

        var instancePropertyDeclarations = [VariableDeclarationStmt]()
        var instanceMethodDeclarations = [FunctionDeclarationStmt]()
        var classPropertyDeclarations = [VariableDeclarationStmt]()
        var classMethodDeclarations = [FunctionDeclarationStmt]()
        var innerClassDeclarations = [ClassDeclarationStmt]()

        var noAnymoreStatement = false
        while true {
            if currentToken == .eof {
                throw ParserError.expressionError
            }
            
            if currentToken == .lf {
                try getNextToken() // Consume line feed
                continue
            }
            
            if currentToken == .rightCurlyBrace {
                break
            }
            
            if noAnymoreStatement {
                throw ParserError.expressionError
            }
            
            // Instance member declarations
            
            if currentToken == .variable,
                let instanceVariableDeclaration = try parseVariableDeclarationStatement() as? VariableDeclarationStmt {
                instancePropertyDeclarations.append(instanceVariableDeclaration)
                continue
            }
            
            if currentToken == .constant,
                let instanceConstantDeclaration = try parseConstantDeclarationStatement() as? VariableDeclarationStmt {
                instancePropertyDeclarations.append(instanceConstantDeclaration)
                continue
            }
            
            if currentToken == .funcToken,
                let instanceMethodDeclaration = try parseFunctionStatement() as? FunctionDeclarationStmt {
                instanceMethodDeclarations.append(instanceMethodDeclaration)
                continue
            }
            
            // Class member declarations
            
            if currentToken == .staticToken {
                
                try getNextToken() // Consume 'static'
                
                if currentToken == .variable,
                    let classVariableDeclaration = try parseVariableDeclarationStatement() as? VariableDeclarationStmt {
                    classPropertyDeclarations.append(classVariableDeclaration)
                    continue
                }
                
                if currentToken == .constant,
                    let classConstantDeclaration = try parseConstantDeclarationStatement() as? VariableDeclarationStmt {
                    classPropertyDeclarations.append(classConstantDeclaration)
                    continue
                }
                
                if currentToken == .funcToken,
                    let classMethodDeclaration = try parseFunctionStatement() as? FunctionDeclarationStmt {
                    classMethodDeclarations.append(classMethodDeclaration)
                    continue
                }
            }
            
            if currentToken == .classToken,
                let innerClassDeclaration = try parseClassDeclarationStatement() as? ClassDeclarationStmt {
                innerClassDeclarations.append(innerClassDeclaration)
                continue
            }
            
            noAnymoreStatement = true
        }
        
        try getNextToken() // Consume '}'
        
        
        guard currentToken == .lf else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume line feed

        return ClassDeclarationStmt(name: name,
                                    superclassExpr: superclassExpr,
                                    classPropertyDeclarations: classPropertyDeclarations,
                                    classMethodDeclarations: classMethodDeclarations,
                                    instancePropertyDeclarations: instancePropertyDeclarations,
                                    instanceMethodDeclarations: instanceMethodDeclarations,
                                    innerClassDeclarations: innerClassDeclarations)
    }
    
    // MARK: - Expressions parsing
    
    /**
     
     Primary expressions parsing
     
     primary
        ::= identifierexpr
        ::= integerExpr
        ::= realExpr
        ::= booleanExpr
        ::= stringExpr
        ::= parenExpr
     
    */
    private func parsePrimaryExpression() throws -> Evaluable? {
        switch currentToken! {
        case .identifier:
            return try parseIdentifierExpression()
            
        case .integer:
            return try parseIntegerExpression()
            
        case .real:
            return try parseRealExpression()
            
        case .boolean:
            return try parseBooleanExpression()
            
        case .string:
            return try parseStringExpression()
            
        case .leftParenthesis:
            return try parseParenthesisExpression()
            
        case .superToken:
            return try parseSuperExpression()
            
        default:
            return nil
        }
    }
    
    /// identifierexpr
    ///   ::= identifier
    ///   ::= identifier '(' expression* ')'
    private func parseIdentifierExpression() throws -> Evaluable? {
        guard let name = lexer.currentTokenValue as? String else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume identifer token
        
        guard currentToken == .leftParenthesis else {
            // Variable parsing
            return IdentifierExpr(name: name)
        }
        
        // Function call parsing
        try getNextToken() // consume left parenthesis: (
        
        var arguments = [FunctionCallArgument]()
        
        if currentToken! != .rightParenthesis {
            while true {
                if let expression = try parseExpression() {
                    if let identifierExpr = expression as? IdentifierExpr {
                        if currentToken == .colon {
                            try getNextToken() // Consume ':'
                            
                            if let expression = try parseExpression() {
                                // Named argument
                                arguments.append(FunctionCallArgument(name: identifierExpr.name, expr: expression))
                                
                            } else {
                                throw ParserError.expressionError
                            }
                        } else {
                            // Anonymous argument
                            arguments.append(FunctionCallArgument(name: nil, expr: identifierExpr))
                        }
                    } else {
                        // Anonymous argument
                        arguments.append(FunctionCallArgument(name: nil, expr: expression))
                    }
                } else {
                    throw ParserError.expressionError
                }
                
                if currentToken == .rightParenthesis {
                    break
                }
                
                if currentToken == .comma {} else {
                    throw ParserError.expressionError
                }
                
                try getNextToken() // Consume comma
            }
        }
        
        try getNextToken() // Consume right parenthesis: )
        
        return FunctionCallExpr(name: name,
                                arguments: arguments.count > 0 ? arguments : nil)
    }
    
    private func parseFunctionCallArgument() throws -> FunctionCallArgument? {
        if case Token.eof = currentToken! {
            return nil
        }
        
        if currentToken == .identifier {
            
            guard let name = lexer.currentTokenValue as? String else {
                // TODO: good error handling
                throw ParserError.expressionError
            }
            
            try getNextToken() // Consume identifier
            
            if currentToken == .colon {
                try getNextToken() // Consume colon
                
                if let expression = try parseExpression() {
                    // Named argument
                    return FunctionCallArgument(name: name, expr: expression)
                } else {
                    throw ParserError.expressionError
                }
            } else if let expression = try parseBinOpRHS(lhs: IdentifierExpr(name: name), expressionPrecedence: 0) {
                // Anonymous argument
                return FunctionCallArgument(name: nil, expr: expression)
                
            } else {
                throw ParserError.expressionError
            }
        } else if let expression = try parseExpression() {
            // Anonymous argument
            return FunctionCallArgument(name: nil, expr: expression)
            
        } else {
            throw ParserError.expressionError
        }
    }
    
    /**
     
    */
    private func parseIntegerExpression() throws -> IntegerExpr {
        guard let value = lexer.currentTokenValue as? Int else {
            // TODO: good erro handling
            throw ParserError.expressionError
        }
        
        let integerExpression = IntegerExpr(value: value)
        try getNextToken() // consume the integer number
        return integerExpression
    }
    
    /**
     
     */
    private func parseRealExpression() throws -> RealExpr {
        guard let value = lexer.currentTokenValue as? Double else {
            // TODO: good erro handling
            throw ParserError.expressionError
        }
        
        let realExpression = RealExpr(value: value)
        try getNextToken() // consume the real number
        return realExpression
    }
    
    /**
     
     */
    private func parseBooleanExpression() throws -> BooleanExpr {
        guard let value = lexer.currentTokenValue as? Bool else {
            // TODO: good erro handling
            throw ParserError.expressionError
        }
        
        let booleanExpression = BooleanExpr(value: value)
        try getNextToken() // consume the boolean
        return booleanExpression
    }
    
    /**
     
     */
    private func parseStringExpression() throws -> StringExpr {
        guard let value = lexer.currentTokenValue as? String else {
            // TODO: good erro handling
            throw ParserError.expressionError
        }
        
        let stringExpression = StringExpr(value: value)
        try getNextToken() // consume the string
        return stringExpression
    }
    
    /// parenexpr ::= '(' expression ')'
    private func parseParenthesisExpression() throws -> Evaluable? {
        try getNextToken() // consume left parenthesis: (
        let parsedExpression = try parseExpression()
        if parsedExpression == nil {
            return nil
        }
        
        guard case Token.rightParenthesis = currentToken! else {
            throw ParserError.expressionError
        }
        
        try getNextToken() // Consume right parenthesis: )
        
        return parsedExpression
    }
    
    /**
     
     */
    private func parseSuperExpression() throws -> Evaluable {
        try getNextToken() // consume 'super'
        
        return SuperExpr()
    }
    
    /// unary
    ///   ::= primary
    ///   ::= '!' unary
    private func parseUnaryExpression() throws -> Evaluable? {
        // If the current token is not an operator, it must be a primary expr.
        if !Token.unaryOperatorTokens.contains(currentToken) ||
            currentToken == .leftParenthesis {
            return try parsePrimaryExpression()
        }
    
        // If this is a unary operator, read it.
        let unOp = currentToken!

        try getNextToken() // consume unary operator

        if let operand = try parseUnaryExpression() {
            return UnaryOperatorExpr(unOp: unOp, operand: operand)
        }
        
        return nil
    }
    
    /// binoprhs
    ///   ::= ('+' primary)*
    private func parseBinOpRHS(lhs: Evaluable, expressionPrecedence: Int) throws -> Evaluable? {
        var lhs = lhs
        
        // If this is a binary operator, find its precedence.
        while true {
            let tokenPrecedence = getCurrentTokenPrecedence()
            
            // If this is a binary operator that binds at least as tightly
            // as the current binary operator, consume it, otherwise we are done.
            if tokenPrecedence < expressionPrecedence {
                return lhs
            }
            
            // Okay, we know this is a binop.
            let binOp = currentToken
            try getNextToken() // eat binop
            
            // Parse the primary expression after the binary operator.
            var rhs = try parseUnaryExpression()
            if rhs == nil {
                return nil
            }
            
            // If BinOp binds less tightly with RHS than the operator after RHS, let
            // the pending operator take RHS as its LHS.
            let nextPrecedence = getCurrentTokenPrecedence()
            if tokenPrecedence < nextPrecedence {
                rhs = try parseBinOpRHS(lhs: rhs!, expressionPrecedence: tokenPrecedence + 1)
                if rhs == nil {
                    return nil
                }
            }
            
            // Merge LHS/RHS.
            lhs = BinaryOperatorExpr(binOp: binOp!, lhs: lhs, rhs: rhs!)
        }
    }
    
    /// expression
    ///   ::= primary binoprhs
    ///
    private func parseExpression() throws -> Evaluable? {
        guard let lhs = try parseUnaryExpression() else {
            return nil
        }
        
        return try parseBinOpRHS(lhs: lhs, expressionPrecedence: 0)
    }
    
}
