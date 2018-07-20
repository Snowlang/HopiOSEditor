//
//  Program.swift
//  TestLexer
//
//  Created by poisson florent on 01/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct Program: Loggable {
    
    var block: BlockStmt?
    
    var description: String {
        var description = ""
        if let block = block {
            description += block.description
        }
        return description
    }
    
    func perform() throws {
        let global = Scope(parent: nil)
        let context = Scope(parent: nil)
        importArrayClass(in: context)
        _ = try block?.evaluate(context: context, global: global)
    }

}
