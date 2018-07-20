//
//  BreakStmt.swift
//  TestLexer
//
//  Created by poisson florent on 07/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct BreakStmt: Evaluable {

    var description: String {
        return "break"
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        context.isBreakRequested = true
        return nil
    }
    
}
