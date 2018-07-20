//
//  BooleanExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class BooleanExpr: Evaluable {
    
    let value: Bool
    
    init(value: Bool) {
        self.value = value
    }
    
    var description: String {
        return "Boolean(\(value))"
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        return Variable(type: .boolean, isConstant: true, value: value)
    }
    
}
