//
//  IfStmt.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

/**
 
 If statement
 
 */
struct IfStmt: Evaluable {
    
    var conditionExpression: Evaluable
    var thenBlock: BlockStmt?
    var elseBlock: BlockStmt?
    
    var description: String {
        var description = "if " + conditionExpression.description + " {\n"
        if let thenBlock = thenBlock {
            description += thenBlock.description
        }
        description += "}"
        if let elseBlock = elseBlock {
            description += " else "
            if let firstStatement = elseBlock.statements.first,
                firstStatement is IfStmt {
                description += firstStatement.description
            } else {
                description += "{\n"
                description += elseBlock.description
                description += "}\n"
            }
        }
        return description
    }

    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        guard let conditionVariable = try conditionExpression.evaluate(context: context,
                                                                       environment: environment) as? Variable,
            let conditionValue = conditionVariable.value as? Bool else {
            throw InterpreterError.expressionEvaluationError
        }
        
        if conditionValue {
            _ = try thenBlock?.evaluate(context: context,
                                        environment: environment)
        } else {
            _ = try elseBlock?.evaluate(context: context,
                                        environment: environment)
        }
        
        return nil
    }
    
}
