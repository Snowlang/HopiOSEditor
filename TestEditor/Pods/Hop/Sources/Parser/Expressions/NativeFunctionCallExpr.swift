//
//  NativeFunctionCallExpr.swift
//  TestLexer
//
//  Created by poisson florent on 06/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct NativeFunctionCallExpr : Evaluable {
    
    struct Argument: Loggable {
        var name: String!
        var valueHashId: Int    // Native function call is given direct access to param hash id
        
        var description: String {
            return "\(name): \(valueHashId)"
        }
        
        init(name: String!, valueHashId: Int) {
            self.name = name
            self.valueHashId = valueHashId
        }

    }
    
    private let arguments: [Argument]?
    private let evaluation: (_ arguments: [Variable]?) throws -> Variable?
    private let type: () -> Type
    
    init(arguments: [Argument]?,
         evaluation: @escaping (_ arguments: [Variable]?) throws -> Variable?,
         type: @escaping () -> Type) {
        self.arguments = arguments
        self.evaluation = evaluation
        self.type = type
    }
    
    var description: String {
        var description = "native func call("
        
        if let arguments = arguments {
            for arg in arguments {
                description += arg.description + "\n"
            }
        }
        
        description += ")"
        return description
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        var argumentEvaluations: [Variable]!
        
        // Inject argument value expressions if needed
        if let arguments = self.arguments {
            argumentEvaluations = [Variable]()

            for argument in arguments {
                guard let argumentVariable = context.getSymbolValue(for: argument.valueHashId) as? Variable else {
                    throw InterpreterError.nativeFunctionCallParameterError
                }
                argumentEvaluations.append(argumentVariable)
            }
        }
        
        return try evaluation(argumentEvaluations) ?? Variable(type: .void, isConstant: true, value: nil)
    }
    
}
