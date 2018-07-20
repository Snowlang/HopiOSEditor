//
//  Scope.swift
//  TestLexer
//
//  Created by poisson florent on 01/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation


class Scope {

    static var counterId = 0
    
    let uid: Int
    var name: String?
    let parent: Scope?
    
    var symbolTable = [Int: Evaluable]()
    
    var returnedEvaluable: Evaluable?
    var isBreakRequested: Bool = false
    var isContinueRequested: Bool = false
    
    init(parent: Scope?) {
        self.parent = parent
        self.uid = Scope.counterId
        Scope.counterId += 1
    }

    // MARK: Scope content management
    
    /**
        Search for a symbol and its parent scope
    */
    func getSymbolValue(for hashId: Int) -> Evaluable? {
        if let symbolValue = symbolTable[hashId] {
            return symbolValue
        }
        
        return parent?.getSymbolValue(for: hashId)
    }
    
    func getNamedScopeChain() -> String? {
        guard let rhsName = name else {
                return nil
        }
        
        guard let lshChain = parent?.getNamedScopeChain() else {
            return rhsName
        }
        
        return lshChain + "." + rhsName
    }

}
