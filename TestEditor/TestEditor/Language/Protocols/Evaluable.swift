//
//  Evaluable.swift
//  TestLexer
//
//  Created by poisson florent on 03/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

protocol Evaluable: Loggable {
    
    /**
     
     - Parameter context: current scope,
     
     - Parameter global: global scope for imported modules.
    
     */
    func evaluate(context: Scope, global: Scope) throws -> Evaluable?

}
