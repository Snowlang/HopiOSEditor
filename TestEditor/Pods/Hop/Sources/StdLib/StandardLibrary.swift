//
//  StandardLibrary.swift
//  TestLexer
//
//  Created by poisson florent on 04/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

//
// Notification management
//

// Notifications
public let printNotification = Notification.Name(rawValue: "com.language.printNotification")

// Notification infos keys
public let notificationMessageInfosKey = "notificationMessageInfosKey"

//
// Standard modules definition
//

typealias FunctionClosure = (_ declarationScope: Scope) -> Closure

// Sys module functions
private let sysFunctionDeclarations: [FunctionClosure] = [
    getPrintDeclaration,
    getStringDeclaration
]

// Math module functions
private var mathFunctionsDeclarations: [FunctionClosure] = [
    getAcosDeclaration,
    getAsinDeclaration,
    getAtanDeclaration,
    getAtan2Declaration,
    getCosDeclaration,
    getSinDeclaration,
    getTanDeclaration,
    getAcoshDeclaration,
    getAsinhDeclaration,
    getAtanhDeclaration,
    getCoshDeclaration,
    getSinhDeclaration,
    getTanhDeclaration,
    getExpDeclaration,
    getLogDeclaration,
    getLog10Declaration,
    getFabsDeclaration,
    getHypotDeclaration,
    getPowDeclaration,
    getSqrtDeclaration,
    getCeilDeclaration,
    getFloorDeclaration,
    getRoundDeclaration
]

private let nativesModules: [String: [FunctionClosure]] = [
    "Sys": sysFunctionDeclarations,
    "Math": mathFunctionsDeclarations
]

enum ImporterError: Error {
    case moduleNotFound
}

func getNativeModule(name: String) -> Module? {
    // NOTE: For now, native modules only contain functions
    if let functionDeclarations = nativesModules[name] {
        let scope = Scope(parent: nil)
        functionDeclarations.forEach {
            let closure = $0(scope)
            scope.symbolTable[closure.prototype.hashId] = closure
        }
        return Module(name: name, scope: scope)
    }
    
    return nil
}

func getNativeFunctionClosure(prototype: Prototype,
                              declarationScope: Scope,
                              evaluation: @escaping (_ arguments: [Variable]?) throws -> Variable?) -> Closure {
    // Function declaration
    // ====================
    
    // Body
    // ----
    
    // Native function call expression
    var arguments: [NativeFunctionCallExpr.Argument]?
    if let prototypeArguments = prototype.arguments {
        arguments = [NativeFunctionCallExpr.Argument]()
        for prototypeArgument in prototypeArguments {
            arguments?.append(NativeFunctionCallExpr.Argument(name: nil, valueHashId: prototypeArgument.hashId))
        }
    }
    
    let type = prototype.type
    let nativeFunctionCall = NativeFunctionCallExpr(arguments: arguments, evaluation: evaluation) {
        () -> Type in
        return type
    }

    // Embedding return statement
    let statement = ReturnStmt(result: nativeFunctionCall)
    
    // Body block
    let block = BlockStmt(statements: [statement])
    
    // Function declaration closure
    return Closure(prototype: prototype,
                   block: block,
                   declarationScope: declarationScope)
}

// MARK: - Default standard functions

/// Native binding for print(String)
private func getPrintDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    let argument = Argument(name: "text", type: .string, isAnonymous: true)
    let prototype = Prototype(name: "print", arguments: [argument], type: .void)

    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let string = expressions?.first?.value as? String else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        
        let message = "[\(Date().timeIntervalSinceReferenceDate)] -- \(string)"
        print(message)
        NotificationCenter.default.post(name: printNotification,
                                        object: nil,
                                        userInfo: [notificationMessageInfosKey : message])
        return nil
    }
}

// MARK: - Type conversion

private func getStringDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    let argument = Argument(name: "value", type: .any, isAnonymous: true)
    let prototype = Prototype(name: "string", arguments: [argument], type: .string)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let variable = expressions?.first else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        
        if let integer = variable.value as? Int {
            return Variable(type: .string, isConstant: true, value: String(integer))
            
        } else if let real = variable.value as? Double {
            return Variable(type: .string, isConstant: true, value: String(real))
            
        } else if let boolean = variable.value as? Bool {
            return Variable(type: .string, isConstant: true, value: String(boolean))
            
        } else if let string = variable.value as? String {
            return Variable(type: .string, isConstant: true, value: string)
        }
        
        return Variable(type: .string, isConstant: true, value: "")    // TODO: throwing error instead of default empty value
    }
}

// MARK: - Math functions

/// Native binding for acos(Double) -> Double
private func getAcosDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "acos", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: acos(value))
    }
}

/// Native binding for asin(Double) -> Double
private func getAsinDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "asin", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: asin(value))
    }
}

/// Native binding for atan(Double) -> Double
private func getAtanDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "atan", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: atan(value))
    }
}

/// Native binding for atan2(Double, Double) -> Double
private func getAtan2Declaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let xArgument = Argument(name: "x", type: .real, isAnonymous: true)
    let yArgument = Argument(name: "y", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "atan2", arguments: [xArgument, yArgument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let expressions = expressions,
            expressions.count == 2,
            let x = expressions[0].value as? Double,
            let y = expressions[1].value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: atan2(x, y))
    }
}

/// Native binding for cos(Double) -> Double
private func getCosDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "cos", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: cos(value))
    }
}

/// Native binding for sin(Double) -> Double
private func getSinDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "angle", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "sin", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: sin(value))
    }
}

/// Native binding for tan(Double) -> Double
private func getTanDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "tan", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: tan(value))
    }
}

/// Native binding for acosh(Double) -> Double
private func getAcoshDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "acosh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: acosh(value))
    }
}

/// Native binding for asinh(Double) -> Double
private func getAsinhDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "asinh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: asinh(value))
    }
}

/// Native binding for atanh(Double) -> Double
private func getAtanhDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "atanh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: atanh(value))
    }
}

/// Native binding for cosh(Double) -> Double
private func getCoshDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "cosh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: cosh(value))
    }
}

/// Native binding for sinh(Double) -> Double
private func getSinhDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "sinh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: sinh(value))
    }
}

/// Native binding for tanh(Double) -> Double
private func getTanhDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "tanh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: tanh(value))
    }
}

/// Native binding for exp(Double) -> Double
private func getExpDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "exp", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: exp(value))
    }
}

/// Native binding for log(Double) -> Double
private func getLogDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "log", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: log(value))
    }
}

/// Native binding for log10(Double) -> Double
private func getLog10Declaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "log10", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: log10(value))
    }
}

/// Native binding for fabs(Double) -> Double
private func getFabsDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "fabs", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: fabs(value))
    }
}

/// Native binding for hypot(Double, Double) -> Double
private func getHypotDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let xArgument = Argument(name: "x", type: .real, isAnonymous: true)
    let yArgument = Argument(name: "y", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "hypot", arguments: [xArgument, yArgument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let expressions = expressions,
            expressions.count == 2,
            let x = expressions[0].value as? Double,
            let y = expressions[1].value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: hypot(x, y))
    }
}


/// Native binding for pow(Double, Double) -> Double
private func getPowDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let xArgument = Argument(name: "x", type: .real, isAnonymous: true)
    let yArgument = Argument(name: "y", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "pow", arguments: [xArgument, yArgument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let expressions = expressions,
            expressions.count == 2,
            let x = expressions[0].value as? Double,
            let y = expressions[1].value as? Double else {
                throw InterpreterError.nativeFunctionCallParameterError
        }

        return Variable(type: .real, isConstant: true, value: pow(x, y))
    }
}

/// Native binding for sqrt(Double) -> Double
private func getSqrtDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "sqrt", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: sqrt(value))
    }
}

/// Native binding for ceil(Double) -> Double
private func getCeilDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "ceil", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: ceil(value))
    }
}

/// Native binding for acos(Double) -> Double
private func getFloorDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "floor", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: floor(value))
    }
}

/// Native binding for round(Double) -> Double
private func getRoundDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "round", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw InterpreterError.nativeFunctionCallParameterError
        }
        return Variable(type: .real, isConstant: true, value: round(value))
    }
}

