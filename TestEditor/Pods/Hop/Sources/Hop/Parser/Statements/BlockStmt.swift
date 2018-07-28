//
//  BlockStmt.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation


/**
 
 Block statement
 
 */
struct BlockStmt: Evaluable {
    
    var statements: [Evaluable]
    
    var description: String {
        var description = ""
        for statement in statements {
            description += statement.description + "\n"
        }
        return description
    }
    
    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        // Create block context
        let blockContext = Scope(parent: context)
        
        for statement in statements {
            _ = try statement.evaluate(context: blockContext,
                                       environment: environment)
            
            if blockContext.returnedEvaluable != nil {
                break
            }
            
            if blockContext.isBreakRequested {
                break
            }
            
            if blockContext.isContinueRequested {
                break
            }
        }
        
        // Propagate returned expression, break & continue states to parent if needed
        context.returnedEvaluable = blockContext.returnedEvaluable
        context.isBreakRequested = blockContext.isBreakRequested
        context.isContinueRequested = blockContext.isContinueRequested

        return nil
    }
    
}
