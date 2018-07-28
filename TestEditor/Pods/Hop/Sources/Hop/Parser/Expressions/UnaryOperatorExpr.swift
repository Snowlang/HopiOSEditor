//
//  UnaryOperatorExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct UnaryOperatorExpr: Evaluable {
    
    var unOp: Token
    var operand: Evaluable
    
    var description: String {
        return "\(unOp.rawValue)" + operand.description
    }
    
    func evaluate(context: Scope,
                  environment: Environment) throws -> Evaluable? {
        switch unOp {
        case .onesComplement:
            return try evaluateOnesComplement(context: context,
                                              environment: environment)
        case .logicalNegation:
            return try evaluateLogicalNegation(context: context,
                                               environment: environment)
        case .plus:
            return try evaluatePlus(context: context,
                                    environment: environment)
        case .minus:
            return try evaluateMinus(context: context,
                                     environment: environment)
        default:
            return nil
        }
    }
    
    private func evaluateOnesComplement(context: Scope,
                                        environment: Environment) throws -> Evaluable? {
        
        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           environment: environment) as? Variable else {
            throw InterpreterError.expressionEvaluationError
        }
        
        guard evaluatedVariable.type == .integer else {
            throw InterpreterError.expressionEvaluationError
        }
        
        guard let evaluatedValue = evaluatedVariable.value else {
            throw InterpreterError.undefinedVariable
        }
        
        return Variable(type: .integer, isConstant: true, value: ~(evaluatedValue as! Int))
    }
    
    private func evaluateLogicalNegation(context: Scope,
                                         environment: Environment) throws -> Evaluable? {
        
        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           environment: environment) as? Variable else {
            throw InterpreterError.expressionEvaluationError
        }

        guard evaluatedVariable.type == .boolean else {
            throw InterpreterError.expressionEvaluationError
        }
        
        guard let evaluatedValue = evaluatedVariable.value else {
            throw InterpreterError.undefinedVariable
        }

        return Variable(type: .boolean, isConstant: true, value: !(evaluatedValue as! Bool))
    }
    
    private func evaluatePlus(context: Scope,
                              environment: Environment) throws -> Evaluable? {
        
        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           environment: environment) as? Variable else {
            throw InterpreterError.expressionEvaluationError
        }
        
        // NOTE: First, varibale type is checked,
        //       then, variable value setting is checked.
        
        if evaluatedVariable.type == .integer {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw InterpreterError.undefinedVariable
            }
            return Variable(type: .integer,
                            isConstant: true,
                            value: (evaluatedValue as! Int))
            
        } else if evaluatedVariable.type == .real {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw InterpreterError.undefinedVariable
            }
            return Variable(type: .real,
                            isConstant: true,
                            value: (evaluatedValue as! Double))
        } else {
            throw InterpreterError.expressionEvaluationError
        }
    }
    
    private func evaluateMinus(context: Scope,
                               environment: Environment) throws -> Evaluable? {
        
        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           environment: environment) as? Variable else {
            throw InterpreterError.expressionEvaluationError
        }
        
        // NOTE: First, varibale type is checked,
        //       then, variable value setting is checked.
        
        if evaluatedVariable.type == .integer {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw InterpreterError.undefinedVariable
            }
            return Variable(type: .integer,
                            isConstant: true,
                            value: -(evaluatedValue as! Int))

        } else if evaluatedVariable.type == .real {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw InterpreterError.undefinedVariable
            }
            return Variable(type: .real,
                            isConstant: true,
                            value: -(evaluatedValue as! Double))
        } else {
            throw InterpreterError.expressionEvaluationError
        }
    }
    
}
