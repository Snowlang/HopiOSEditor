//
//  Module.swift
//  TestLexer
//
//  Created by poisson florent on 17/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class Module: Evaluable {

    let name: String
    let hashId: Int
    let scope: Scope
    
    init(name: String, scope: Scope) {
        self.name = name
        self.hashId = name.hashValue
        self.scope = scope
        self.scope.name = name // Module scope is named
    }
    
    var description: String {
        return "Module(\(name))"
    }

    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        return self
    }
    
}
