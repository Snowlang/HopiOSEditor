//
//  ReturnStmt.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

/**
 
 Return statement
 
 */
struct ReturnStmt: Evaluable {
    
    var result: Evaluable?
    
    var description: String {
        var description = "return"
        if let result = result {
            description += " " + result.description
        }
        return description
    }
    
    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        if let result = result {
            guard let resultVariable = try result.evaluate(context: context,
                                                           environment: environment) as? Variable else {
                throw InterpreterError.expressionEvaluationError
            }
            context.returnedEvaluable = resultVariable
        } else {
            context.returnedEvaluable = Variable(type: .void, isConstant: true, value: nil)
        }
        return nil
    }
    
}
