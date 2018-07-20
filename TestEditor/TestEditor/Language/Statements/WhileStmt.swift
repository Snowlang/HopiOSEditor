//
//  WhileStmt.swift
//  TestLexer
//
//  Created by poisson florent on 07/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class WhileStmt: Evaluable {

    private let conditionExpression: Evaluable
    private let block: BlockStmt
    
    init(conditionExpression: Evaluable, block: BlockStmt) {
        self.conditionExpression = conditionExpression
        self.block = block
    }
    
    var description: String {
        var description = "while "
            + conditionExpression.description
            + " {\n"
        description += block.description
        description += "}\n"
        return description
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        
        func evaluateCondition(_ expression: Evaluable, context: Scope, global: Scope) throws -> Bool {
            guard let conditionVariable = try expression.evaluate(context: context, global: global) as? Variable,
                let conditionValue = conditionVariable.value as? Bool else {
                    throw InterpreterError.expressionEvaluationError
            }
            return conditionValue
        }
        
        while try evaluateCondition(conditionExpression, context: context, global: global) {

            _ = try block.evaluate(context: context, global: global)
            
            if context.returnedEvaluable != nil {
                break
            }

            if context.isBreakRequested {
                context.isBreakRequested = false
                break
            }

            if context.isContinueRequested {
                context.isContinueRequested = false
                continue
            }
        }
        
        return nil
    }
    
}
