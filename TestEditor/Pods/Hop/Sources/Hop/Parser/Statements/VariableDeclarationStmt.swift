//
//  VariableDeclarationStmt.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

/**
 
 Variable declaration statement
 
 */
class VariableDeclarationStmt: Evaluable {
    
    var name: String
    var hashId: Int
    var typeExpr: Evaluable?
    var isConstant: Bool
    var isPrivate: Bool
    var expr: Evaluable?
    
    init(name: String,
         typeExpr: Evaluable?,
         isConstant: Bool,
         isPrivate: Bool,
         expr: Evaluable?) {
        self.name = name
        self.hashId = name.hashValue
        self.typeExpr = typeExpr
        self.isConstant = isConstant
        self.isPrivate = isPrivate
        self.expr = expr
    }
    
    var description: String {
        var description = "\(isConstant ? "const" : "var") \(name): \(typeExpr?.description ?? "Undefined")"
        if let expr = expr {
            description += " = \(expr.description)"
        }
        return description
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        // Check for identifier redeclaration
        guard context.symbolTable[hashId] == nil else {
            throw InterpreterError.invalidRedeclaration
        }
        
        var type: Type!
        // Check for type if defined
        if let typeExpr = typeExpr {
            if let identifierType = typeExpr as? IdentifierExpr,
                Type.basicTypeHashIds.contains(identifierType.hashId) {
                type = Type(name: identifierType.name)
                
            } else if let evaluatedType = try typeExpr.evaluate(context: context, global: global),
                let `class` = evaluatedType as? Class {
                type = `class`.type
            }
            
            if type == nil {
                throw InterpreterError.undefinedType
            }
        }
        
        // Get value expression if needed
        var variable: Variable!
        if let expr = expr {
            let evaluatedVariable = try expr.evaluate(context: context, global: global) as? Variable
            if evaluatedVariable == nil {
                throw InterpreterError.expressionEvaluationError
            }

            variable = Variable(type: evaluatedVariable!.type,
                                isConstant: isConstant,
                                value: evaluatedVariable!.value)

            if let type = type {
                // Check if types match
                if type != .any {     // `Any` welcome any type
                    if type != evaluatedVariable!.type {
                        if let instance = evaluatedVariable!.value as? Instance {
                            if !instance.isInstance(of: type) {
                                throw InterpreterError.expressionTypeMismatch
                            }
                        } else if evaluatedVariable!.type != .nil {
                            throw InterpreterError.expressionTypeMismatch
                        }
                        variable.type = type
                    }
                }
            } else if evaluatedVariable!.type == .nil {
                throw InterpreterError.undefinedType
            }
        } else if let type = type {
            variable = Variable(type: type, isConstant: isConstant, value: nil)
            
        } else {
            throw InterpreterError.undefinedType
        }

        // Add variable to current scope
        context.symbolTable[hashId] = variable
        
        return nil
    }
    
}
