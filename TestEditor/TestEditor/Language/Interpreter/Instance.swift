//
//  Instance.swift
//  TestLexer
//
//  Created by poisson florent on 18/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class Instance {

    let scope: Scope
    let `class`: Class
    var refCount: Int = 0
    
    init(class: Class, scope: Scope) {
        self.class = `class`
        self.scope = scope
    }

    func isInstance(of type: Type) -> Bool {
        return `class`.isSubclass(of: type)
    }
    
//    deinit {
//        print("--> deinit of instance of type: \(type.name)")
//    }
    
    func clearProperties() {
        scope.symbolTable.removeAll()
    }

}
