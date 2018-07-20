//
//  FunctionCallArgument.swift
//  TestLexer
//
//  Created by poisson florent on 11/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct FunctionCallArgument: Loggable {
    var name: String!
    var expr: Evaluable
    
    var description: String {
        return "\(name != nil ? "\(name): " : "")\(expr.description)"
    }
    
    init(name: String!, expr: Evaluable) {
        self.name = name
        self.expr = expr
    }
    
}
