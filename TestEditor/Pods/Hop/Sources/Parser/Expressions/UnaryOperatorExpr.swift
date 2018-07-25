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
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        switch unOp {
        case .onesComplement:
            return try evaluateOnesComplement(context: context, global: global)
        case .logicalNegation:
            return try evaluateLogicalNegation(context: context, global: global)
        case .plus:
            return try evaluatePlus(context: context, global: global)
        case .minus:
            return try evaluateMinus(context: context, global: global)
        default:
            return nil
        }
    }
    
    private func evaluateOnesComplement(context: Scope, global: Scope) throws -> Evaluable? {
        guard let evaluatedVariable = try operand.evaluate(context: context, global: global) as? Variable,
            let intergerValue = evaluatedVariable.value as? Int else {
            throw InterpreterError.expressionEvaluationError
        }
        
        return Variable(type: .integer, isConstant: true, value: ~intergerValue)
    }
    
    private func evaluateLogicalNegation(context: Scope, global: Scope) throws -> Evaluable? {
        guard let evaluatedVariable = try operand.evaluate(context: context, global: global) as? Variable,
            let booleanValue = evaluatedVariable.value as? Bool else {
            throw InterpreterError.expressionEvaluationError
        }
        
        return Variable(type: .boolean, isConstant: true, value: !booleanValue)
    }
    
    private func evaluatePlus(context: Scope, global: Scope) throws -> Evaluable? {
        guard let evaluatedVariable = try operand.evaluate(context: context, global: global) as? Variable else {
            throw InterpreterError.expressionEvaluationError
        }
        
        if let integerValue = evaluatedVariable.value as? Int {
            return Variable(type: .boolean, isConstant: true, value: integerValue)
            
        } else if let realValue = evaluatedVariable.value as? Double {
            return Variable(type: .boolean, isConstant: true, value: realValue)
        } else {
            throw InterpreterError.expressionEvaluationError
        }
    }
    
    private func evaluateMinus(context: Scope, global: Scope) throws -> Evaluable? {
        guard let evaluatedVariable = try operand.evaluate(context: context, global: global) as? Variable else {
            throw InterpreterError.expressionEvaluationError
        }
        
        if let integerValue = evaluatedVariable.value as? Int {
            return Variable(type: .integer, isConstant: true, value: -integerValue)
            
        } else if let realValue = evaluatedVariable.value as? Double {
            return Variable(type: .real, isConstant: true, value: -realValue)
            
        } else {
            throw InterpreterError.expressionEvaluationError
        }
    }
    
}
