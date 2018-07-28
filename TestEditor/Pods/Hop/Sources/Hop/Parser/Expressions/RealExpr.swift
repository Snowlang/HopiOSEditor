//
//  RealExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class RealExpr: Evaluable {
    
    let value: Double
    
    init(value: Double) {
        self.value = value
    }
    
    var description: String {
        return "Real(\(value))"
    }
    
    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        return Variable(type: .real, isConstant: true, value: value)
    }
    
}
