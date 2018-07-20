//
//  StringExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class StringExpr: Evaluable {
    
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    var description: String {
        return "String(\(value))"
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        return Variable(type: .string, isConstant: true, value: value)
    }
    
}
