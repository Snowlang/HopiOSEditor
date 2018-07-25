//
//  LanguageExtensions.swift
//  TestLexer
//
//  Created by poisson florent on 02/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

func importArrayClass(in context: Scope) {
    
    let name = "Array"
    
    let classScope = Scope(parent: context)
    
    // Instance private property '__array__'
    let privateArrayDeclaration = VariableDeclarationStmt(name: "__array__",
                                                          typeExpr: IdentifierExpr(name: "Any"),
                                                          isConstant: false,
                                                          isPrivate: true,  // TODO: implement flag checking at assignment
                                                          expr: nil)

    // Instance methods & init/deinit
    // ------------------------------

    let selfArgument = Argument(name: SelfParameter.name,
                                type: Type(name: name),
                                isAnonymous: false)
        
    // Default initializer: Array()
    computeInitializer(in: classScope, selfArgument: selfArgument)
    
    // method:  func append(#element: Any)
    computeMethodAppendElement(in: classScope, selfArgument: selfArgument)

    // method:  func append(contentOf: Array)

    // method:  func setElement(#element: Any, at: Int)

    // method:  func remove(at: <index>)

    // method:  func insert(#element: Any, at: Int)

    // method:  func popFirst()

    // method:  func popLast()

    // method:  func first()

    // method:  func last()

    // method:  func element(at: Int)
    computeMethodElementAt(in: classScope, selfArgument: selfArgument)

    // method:  func isEmpty()

    // method:  func count()

    // method:  func shuffled()

    // method:  func reversed()
    
    context.symbolTable[name.hashValue] = Class(name: name,
                                                superclass: nil,
                                                instancePropertyDeclarations: [privateArrayDeclaration],
                                                scope: classScope)
}

private func computeInitializer(in classScope: Scope,
                            selfArgument: Argument) {
    // Array initialization
    // --------------------
    // 'self.__array__ = <Array Variable>
    let arrayExpr = BinaryOperatorExpr(binOp: .dot,
                                       lhs: IdentifierExpr(name: SelfParameter.name),
                                       rhs: IdentifierExpr(name: "__array__"))

    // Native function call expression for instanstiating swift array
    let nativeArrayExpr = NativeFunctionCallExpr(arguments: nil, evaluation: { (_) -> Variable? in
        return Variable(type: .any, isConstant: true, value: NSMutableArray())
    }) {
        return Type.any
    }

    let arrayAssignmentExpr = BinaryOperatorExpr(binOp: .assignment,
                                                 lhs: arrayExpr,
                                                 rhs: nativeArrayExpr)
    let arrayAssignmentStmt = ExpressionStmt(expr: arrayAssignmentExpr)
    
    // Fill block statement
    let blockStmt = BlockStmt(statements: [arrayAssignmentStmt])

    // Get prototype
    let prototype = Prototype(name: ClassInitializer.name,
                              arguments: [selfArgument],
                              type: .void)
    
    // Set closure in class scope
    classScope.symbolTable[prototype.hashId] = Closure(prototype: prototype,
                                                       block: blockStmt,
                                                       declarationScope: classScope)
}

private func computeMethodAppendElement(in classScope: Scope,
                                    selfArgument: Argument) {
    // Prototype
    // ---------
    let elementArgument = Argument(name: "element", type: .any, isAnonymous: true)
    let prototype = Prototype(name: "append",
                              arguments: [selfArgument, elementArgument],
                              type: .void)

    let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
        (arguments) in
        
        // Self argument
        guard let selfInstance = arguments?[0].value as? Instance,
            let element = arguments?[1].value else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        
        guard let arrayVariable = selfInstance.scope.getSymbolValue(for: "__array__".hashValue) as? Variable,
            let array = arrayVariable.value as? NSMutableArray else {
            throw InterpreterError.expressionEvaluationError
        }
        
        array.add(element)
        
        return nil
    }
    
    // Set closure in class scope
    classScope.symbolTable[prototype.hashId] = closure
}

// method:  func append(contentOf: Array)

// method:  func setElement(#element: Any, at: Int)
private func computeMethodSetElementAt(in classScope: Scope,
                                       selfArgument: Argument) {
    
}

// method:  func remove(at: <index>)
private func computeMethodRemoveAt(in classScope: Scope,
                                   selfArgument: Argument) {
    
}

// method:  func insert(#element: Any, at: Int)
private func computeMethodInsertAt(in classScope: Scope,
                                   selfArgument: Argument) {
    
}

// method:  func popFirst()
private func computeMethodPopFirst(in classScope: Scope,
                                   selfArgument: Argument) {
    
}

// method:  func popLast()
private func computeMethodPopLast(in classScope: Scope,
                                  selfArgument: Argument) {
    
}

// method:  func first()
private func computeMethodFirst(in classScope: Scope,
                                selfArgument: Argument) {
    
}

// method:  func last()
private func computeMethodLast(in classScope: Scope,
                               selfArgument: Argument) {

}

private func computeMethodElementAt(in classScope: Scope,
                                selfArgument: Argument) {
    // Prototype
    // ---------
    let atArgument = Argument(name: "at", type: .integer, isAnonymous: false)
    let prototype = Prototype(name: "element",
                              arguments: [selfArgument, atArgument],
                              type: .any)
    
    let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
        (arguments) in
        
        // Self argument
        guard let selfInstance = arguments?[0].value as? Instance,
            let index = arguments?[1].value as? Int else {
                throw InterpreterError.nativeFunctionCallParameterError
        }
        
        guard let arrayVariable = selfInstance.scope.getSymbolValue(for: "__array__".hashValue) as? Variable,
            let array = arrayVariable.value as? NSMutableArray else {
            throw InterpreterError.expressionEvaluationError
        }
        
        guard index >= 0 || index < array.count - 1 else {
            throw InterpreterError.expressionEvaluationError
        }
        
        let element = array.object(at: index)
        
        return Variable(type: Type.type(of: element),
                        isConstant: true,
                        value: element)
    }
    
    // Set closure in class scope
    classScope.symbolTable[prototype.hashId] = closure
}

// method: func isEmpty()
private func computeMethodIsEmpty(in classScope: Scope,
                                  selfArgument: Argument) {
    // Prototype
    // ---------
    let prototype = Prototype(name: "isEmpty",
                              arguments: [selfArgument],
                              type: .boolean)
    
    let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
        (arguments) in
        
        // Self argument
        guard let selfInstance = arguments?.first?.value as? Instance else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        
        guard let arrayVariable = selfInstance.scope.getSymbolValue(for: "__array__".hashValue) as? Variable,
            let array = arrayVariable.value as? NSMutableArray else {
                throw InterpreterError.expressionEvaluationError
        }
        
        return Variable(type: .boolean,
                        isConstant: true,
                        value: (array.count == 0))
    }
    
    // Set closure in class scope
    classScope.symbolTable[prototype.hashId] = closure
}

// method:  func count()
private func computeMethodCount(in classScope: Scope,
                                selfArgument: Argument) {
    // Prototype
    // ---------
    let prototype = Prototype(name: "count",
                              arguments: [selfArgument],
                              type: .integer)
    
    let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
        (arguments) in
        
        // Self argument
        guard let selfInstance = arguments?.first?.value as? Instance else {
                throw InterpreterError.nativeFunctionCallParameterError
        }
        
        guard let arrayVariable = selfInstance.scope.getSymbolValue(for: "__array__".hashValue) as? Variable,
            let array = arrayVariable.value as? NSMutableArray else {
                throw InterpreterError.expressionEvaluationError
        }

        return Variable(type: .integer,
                        isConstant: true,
                        value: array.count)
    }
    
    // Set closure in class scope
    classScope.symbolTable[prototype.hashId] = closure
}

// method:  func shuffled()

// method:  func reversed()

