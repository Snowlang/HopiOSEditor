//
//  FunctionDeclarationStmt.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation


/**
 
 Function declaration statement
 
 */
class FunctionDeclarationStmt: Evaluable {
    
    var prototype: FunctionDeclarationPrototype
    var block: BlockStmt?
    
    init(prototype: FunctionDeclarationPrototype, block: BlockStmt?) {
        self.prototype = prototype
        self.block = block
    }
    
    var description: String {
        var description = "func " + prototype.description + " {\n"
        if let block = block {
            description += block.description
        }
        description += "}\n"
        
        return description
    }

    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        // Compute closure arguments
        var closureArguments: [Argument]?
        
        if let declaredArguments = prototype.arguments,
            declaredArguments.count > 0 {
            
            closureArguments = [Argument]()
            
            for declaredArgument in declaredArguments {
                // Check if type exists
                let type: Type
                if let identifierType = declaredArgument.typeExpr as? IdentifierExpr,
                    Type.basicTypeHashIds.contains(identifierType.hashId) {
                    type = Type(name: identifierType.name)
                    
                } else if let evaluatedType = try declaredArgument.typeExpr.evaluate(context: context, global: global),
                    let `class` = evaluatedType as? Class {
                    type = `class`.type
                
                } else {
                    throw InterpreterError.undefinedType
                }
                
                closureArguments?.append(Argument(name: declaredArgument.name,
                                                  type: type,
                                                  isAnonymous: declaredArgument.isAnonymous))
            }
        }
        
        // Compute closure prototype
        var type = Type.void
        
        if let typeExpr = prototype.typeExpr {
            if let identifierType = typeExpr as? IdentifierExpr,
                Type.basicTypeHashIds.contains(identifierType.hashId) {
                type = Type(name: identifierType.name)
                
            } else if let evaluatedType = try typeExpr.evaluate(context: context, global: global),
                let `class` = evaluatedType as? Class {
                type = `class`.type
            } else {
                throw InterpreterError.undefinedType
            }
        }
        
        let closurePrototype = Prototype(name: prototype.name,
                                         arguments: closureArguments,
                                         type: type)
        
        guard context.symbolTable[closurePrototype.hashId] == nil else {
            throw InterpreterError.functionAlreadyDeclared
        }
        
        // Add closure in context
        context.symbolTable[closurePrototype.hashId] = Closure(prototype: closurePrototype,
                                                               block: block,
                                                               declarationScope: context)
        return nil
    }

}
