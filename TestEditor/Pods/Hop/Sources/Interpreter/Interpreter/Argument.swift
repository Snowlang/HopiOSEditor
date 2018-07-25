//
//  Argument.swift
//  TestLexer
//
//  Created by poisson florent on 26/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct Argument {

    var name: String
    var hashId: Int
    var type: Type
    var isAnonymous: Bool
    var isConstant: Bool = true
    
    init(name: String,
         type: Type,
         isAnonymous: Bool) {
        self.name = name
        self.hashId = name.hashValue
        self.type = type
        self.isAnonymous = isAnonymous
    }
    
}
