//
//  Prototype.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation


struct FunctionDeclarationPrototype: Loggable {

    var name: String
    var arguments: [FunctionDeclarationArgument]?  // Arguments are optional
    var typeExpr: Evaluable?    // Returned value is optional
    
    init(name: String,
         arguments: [FunctionDeclarationArgument]?,
         typeExpr: Evaluable?) {
        self.name = name
        self.arguments = arguments
        self.typeExpr = typeExpr
    }
    
    var description: String {
        var description = name + "("
        if let arguments = arguments {
            for argument in arguments {
                description += argument.description + "\n"
            }
        }
        description += ")"
        if let typeExpr = typeExpr {
            description += " => \(typeExpr.description)"
        }
        return description
    }
    
}
