//
//  Interpreter.swift
//  TestLexer
//
//  Created by poisson florent on 01/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

enum InterpreterError: Error {
    case invalidRedeclaration
    case unresolvedIdentifier
    case forbiddenAssignment
    case forbiddenFunctionCall
    case variableNotDeclared
    case variableNotInitialized
    case classAlreadyDeclared
    case functionAlreadyDeclared
    case functionNotDeclared
    case blueprintAlreadyDeclared
    case wrongUnaryOperatorOperandType
    case binaryOperatorTypeError
    case binaryOperatorTypeMismatch
    case returnPathIsMissing
    case shouldReturnNothing
    case shouldReturnSomething
    case wrongReturnedType
    case variableDeclarationTypeError
    case variableDeclarationTypeMismatch
    case forbiddenConstantAssignment
    case expressionEvaluationError
    case expressionTypeMismatch
    case zeroDivisionAttempt
    case wrongFunctionCallArgumentType
    case wrongFunctionCallReturnedType
    case missingReturnedExpression
    case undefinedType
    case nativeFunctionCallParameterError
    case accessorOwnerError
    case accessorMemberError
    case blueprintMemberError
    case instancePropertyNotFound
    case useOfSuperOutsideAClassMember
    case useOfSuperInRootClassMember
    case classMemberAlreadyDeclaredInSuperclass
    case classMemberAlreadyDeclared
    case classMemberNotDeclared
}

class Interpreter {

    private let program: Program
    
    init(program: Program) {
        self.program = program
    }
    
    func execute() throws {
        try program.perform()
    }
    
}
