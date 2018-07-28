//
//  ImportStmt.swift
//  TestLexer
//
//  Created by poisson florent on 17/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class ImportStmt: Evaluable {

    var name: String
    var hashId: Int
    
    init(name: String) {
        self.name = name
        self.hashId = name.hashValue
    }
    
    var description: String {
        return "import \(name)"
    }
        
    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        // Check if module has already been imported in global context
        let module: Module! = environment.modulesScope.symbolTable[hashId] as? Module
        
        if module != nil {
            context.symbolTable[hashId] = module
            return nil
        }
        
        // Try to import from native modules
        if let nativeModule = getNativeModule(name: name) {
            environment.modulesScope.symbolTable[hashId] = nativeModule
            context.symbolTable[hashId] = nativeModule
            return nil
        }
        
        throw ImporterError.moduleNotFound
    }
    
}
