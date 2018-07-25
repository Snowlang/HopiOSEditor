//
//  Class.swift
//  TestLexer
//
//  Created by poisson florent on 20/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class Class: Evaluable {

    let name: String
    let hashId: Int
    let superclass: Class?
    let instancePropertyDeclarations: [VariableDeclarationStmt]?
    let scope: Scope    // Scope stores static properties declaration, static methods & intance methods
    let type: Type
    
    // Constructor used in forward declaration
    init(name: String,
         scope: Scope) {
        self.name = name
        self.hashId = name.hashValue
        self.superclass = nil
        self.instancePropertyDeclarations = nil
        self.scope = scope
        self.scope.name = name  // Class scope is named
        let namedScopeChain = self.scope.getNamedScopeChain()!
        self.type = Type(name: namedScopeChain)
    }
    
    init(name: String,
         superclass: Class?,
         instancePropertyDeclarations: [VariableDeclarationStmt]?,
         scope: Scope) {
        self.name = name
        self.hashId = name.hashValue
        self.superclass = superclass
        self.instancePropertyDeclarations = instancePropertyDeclarations
        self.scope = scope
        self.scope.name = name  // Class scope is named
        let namedScopeChain = self.scope.getNamedScopeChain()!
        self.type = Type(name: namedScopeChain)
    }

    func getSuperclass(for hashId: Int) -> Class? {
        if superclass == nil {
            return nil
        }
        if superclass?.hashId == hashId {
            return superclass
        }
        return superclass?.getSuperclass(for: hashId)
    }
    
    func getClassMember(for hashId: Int) -> Evaluable? {
        if let member = scope.symbolTable[hashId] {
            return member
        }
        
        return superclass?.getClassMember(for:hashId)
    }
    
    func hasInstanceProperty(with hashId: Int) -> Bool {
        if let instancePropertyDeclarations = instancePropertyDeclarations {
            for instancePropertyDeclaration in instancePropertyDeclarations {
                if instancePropertyDeclaration.hashId == hashId {
                    return true
                }
            }
        }
        
        if let superclass = superclass {
            return superclass.hasInstanceProperty(with: hashId)
        }
        
        return false
    }
    
    func getHierarchyInstanceProperties(_ instancePropertyDeclarations: inout [VariableDeclarationStmt]) {
        if let superclass = superclass {
            superclass.getHierarchyInstanceProperties(&instancePropertyDeclarations)
        }
        
        if self.instancePropertyDeclarations != nil {
            instancePropertyDeclarations.append(contentsOf: self.instancePropertyDeclarations!)
        }
    }
    
    func isSubclass(of type: Type) -> Bool {
        if self.type == type {
            return true
        }
        if let superclass = superclass {
            return superclass.isSubclass(of: type)
        }
        return false
    }
        
    var description: String {
        return "Class(\(name))"
    }
    
    func evaluate(context: Scope, global: Scope) throws -> Evaluable? {
        return self
    }
    
}
