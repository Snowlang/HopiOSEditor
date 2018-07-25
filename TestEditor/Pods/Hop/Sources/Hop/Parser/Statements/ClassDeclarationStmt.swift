//
//  ClassDeclarationStmt.swift
//  TestLexer
//
//  Created by poisson florent on 20/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class ClassDeclarationStmt: Evaluable {

    let name: String
    let hashId: Int
    let superclassExpr: Evaluable?
    let classPropertyDeclarations: [VariableDeclarationStmt]?
    let classMethodDeclarations: [FunctionDeclarationStmt]?
    let instancePropertyDeclarations: [VariableDeclarationStmt]?
    let instanceMethodDeclarations: [FunctionDeclarationStmt]?
    let innerClassDeclarations: [ClassDeclarationStmt]?
    
    init(name: String,
         superclassExpr: Evaluable?,
         classPropertyDeclarations: [VariableDeclarationStmt]?,
         classMethodDeclarations: [FunctionDeclarationStmt]?,
         instancePropertyDeclarations: [VariableDeclarationStmt]?,
         instanceMethodDeclarations: [FunctionDeclarationStmt]?,
         innerClassDeclarations: [ClassDeclarationStmt]?) {
        self.name = name
        self.hashId = name.hashValue
        self.superclassExpr = superclassExpr
        self.classPropertyDeclarations = classPropertyDeclarations
        self.classMethodDeclarations = classMethodDeclarations
        self.instancePropertyDeclarations = instancePropertyDeclarations
        self.instanceMethodDeclarations = instanceMethodDeclarations
        self.innerClassDeclarations = innerClassDeclarations
    }
    
    var description: String {
        var description = "class \(name)"
        if let superclassExpr = superclassExpr {
            description += ": \(superclassExpr.description)"
        }
        description += " {\n"
        if let classPropertyDeclarations = self.classPropertyDeclarations {
            for classPropertyDeclaration in classPropertyDeclarations {
                description += classPropertyDeclaration.description + "\n"
            }
        }
        if let classMethodDeclarations = self.classMethodDeclarations {
            for classMethodDeclaration in classMethodDeclarations {
                description += classMethodDeclaration.description + "\n"
            }
        }
        if let instancePropertyDeclarations = self.instancePropertyDeclarations {
            for instancePropertyDeclaration in instancePropertyDeclarations {
                description += instancePropertyDeclaration.description + "\n"
            }
        }
        if let instanceMethodDeclarations = self.instanceMethodDeclarations {
            for instanceMethodDeclaration in instanceMethodDeclarations {
                description += instanceMethodDeclaration.description + "\n"
            }
        }
        if let innerClassDeclarations = self.innerClassDeclarations {
            for innerClassDeclaration in innerClassDeclarations {
                description += innerClassDeclaration.description + "\n"
            }
        }
        description += "}"
        return description
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        if context.symbolTable[hashId] != nil {
            throw InterpreterError.classAlreadyDeclared
        }
        
        let classScope = Scope(parent: context)
        
        // Check locally for instance property redeclaration
        if let instancePropertyDeclarations = instancePropertyDeclarations {
            for instancePropertyDeclaration in instancePropertyDeclarations {
                let count = instancePropertyDeclarations.reduce(0) { (result, declaration) -> Int in
                    return result + (declaration.hashId == instancePropertyDeclaration.hashId ? 1 : 0)
                }
                if count > 1 {
                    throw InterpreterError.classMemberAlreadyDeclared
                }
            }
        }
        
        // Forward declaration for solving self parameter type
        // when evaluating method declaration.
        let forwardClass = Class(name: name,
                                 scope: classScope)
        context.symbolTable[forwardClass.type.hashId] = forwardClass
        
        // Get superclass if any
        var superclass: Class?
        if let superclassExpr = superclassExpr {
            superclass = try superclassExpr.evaluate(context: context, global: global) as? Class
            if superclass == nil {
                throw InterpreterError.unresolvedIdentifier
            }
            
            // Check if subclass does not redeclare one of superclass instance property
            if let instancePropertyDeclarations = instancePropertyDeclarations,
                instancePropertyDeclarations.count > 0 {
                for instancePropertyDeclaration in instancePropertyDeclarations {
                    if superclass!.hasInstanceProperty(with: instancePropertyDeclaration.hashId) {
                        throw InterpreterError.classMemberAlreadyDeclaredInSuperclass
                    }
                }
            }
        }
        
        // Register superclass in class scope
        // Used to evaluate 'super' keyword
        classScope.symbolTable[SuperParameter.hashId] = superclass ?? Null.shared
        
        // Static properties
        if let classPropertyDeclarations = classPropertyDeclarations,
            classPropertyDeclarations.count > 0 {
            for classPropertyDeclaration in classPropertyDeclarations {
                // Check if property is not already declared in superclass
                if superclass?.getClassMember(for: classPropertyDeclaration.hashId) != nil {
                    throw InterpreterError.classMemberAlreadyDeclaredInSuperclass
                }

                _ = try classPropertyDeclaration.evaluate(context: classScope, global: global)
            }
        }
        
        // Static methods
        if let classMethodDeclarations = classMethodDeclarations,
            classMethodDeclarations.count > 0 {
            for classMethodDeclaration in classMethodDeclarations {
                _ = try classMethodDeclaration.evaluate(context: classScope, global: global)
            }
        }
        
        // Instance methods & init/deinit
        
        // Default initializer
//        let selfArgument = [FunctionDeclarationArgument(name: SelfParameter.name,
//                                                        typeExpr: IdentifierExpr(name: name),
//                                                        isAnonymous: false)]
//        let defaultInitializerPrototype = FunctionDeclarationPrototype(name: ClassInitializer.name,
//                                                                       arguments: selfArgument,
//                                                                       typeExpr: nil)
//        let defaultInitializerDeclarationStmt = FunctionDeclarationStmt(prototype: defaultInitializerPrototype,
//                                                                        block: nil)
//        _ = try defaultInitializerDeclarationStmt.evaluate(context: classScope, global: global)

        if let instanceMethodDeclarations = instanceMethodDeclarations,
            instanceMethodDeclarations.count > 0 {
            for instanceMethodDeclaration in instanceMethodDeclarations {
                let prototype = instanceMethodDeclaration.prototype
                var arguments = [FunctionDeclarationArgument]()
                arguments.append(FunctionDeclarationArgument(name: SelfParameter.name,
                                                             typeExpr: IdentifierExpr(name: name),
                                                             isAnonymous: false))
                if prototype.arguments != nil {
                    arguments.append(contentsOf: prototype.arguments!)
                }
                
                let instanceMethodPrototype = FunctionDeclarationPrototype(name: prototype.name,
                                                                           arguments: arguments,
                                                                           typeExpr: prototype.typeExpr)
                let functionDeclarationStmt = FunctionDeclarationStmt(prototype: instanceMethodPrototype,
                                                                      block: instanceMethodDeclaration.block)
                _ = try functionDeclarationStmt.evaluate(context: classScope, global: global)
            }
        }

        // Inner classes
        if let innerClassDeclarations = self.innerClassDeclarations,
            innerClassDeclarations.count > 0 {
            for innerClassDeclaration in innerClassDeclarations {
                _ = try innerClassDeclaration.evaluate(context: classScope, global: global)
            }
        }
        
        let `class` = Class(name: name,
                            superclass: superclass,
                            instancePropertyDeclarations: instancePropertyDeclarations,
                            scope: classScope)
        context.symbolTable[`class`.type.hashId] = `class`

        return nil
    }
    
}
