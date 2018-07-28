//
//  ContinueStmt.swift
//  TestLexer
//
//  Created by poisson florent on 07/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct ContinueStmt: Evaluable {

    var description: String {
        return "continue"
    }
    
    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        context.isContinueRequested = true
        return nil
    }
    
}
