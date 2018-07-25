//
//  Prototype.swift
//  TestLexer
//
//  Created by poisson florent on 26/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct Prototype {

    var name: String
    var hashId: Int
    var arguments: [Argument]?
    var type: Type
    
    init(name: String,
         arguments: [Argument]?,
         type: Type) {
        self.name = name
        let argumentNames = arguments?.map { (argument) -> String in
            return (argument.isAnonymous ? "" : argument.name)
        }
        self.hashId = Closure.getFunctionSignatureHashId(name: name,
                                                         argumentNames: argumentNames)
        self.arguments = arguments
        self.type = type
    }

}
