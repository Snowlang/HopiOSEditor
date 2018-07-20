//
//  Null.swift
//  TestLexer
//
//  Created by poisson florent on 29/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class Null: Evaluable {

    static let shared = Null()
    
    var description: String {
        return "Null"
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        return self
    }
    
}
