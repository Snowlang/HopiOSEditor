//
//  FunctionDeclarationArgument.swift
//  TestLexer
//
//  Created by poisson florent on 26/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct FunctionDeclarationArgument: Loggable {

    var name: String
    var hashId: Int
    var typeExpr: Evaluable
    var isAnonymous: Bool
    var isConstant: Bool = true
    
    init(name: String,
         typeExpr: Evaluable,
         isAnonymous: Bool) {
        self.name = name
        self.hashId = name.hashValue
        self.typeExpr = typeExpr
        self.isAnonymous = isAnonymous
    }
    
    var description: String {
        return name + ": " + typeExpr.description
    }
    
}
