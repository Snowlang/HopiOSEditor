//
//  Environment.swift
//  Hop iOS
//
//  Created by poisson florent on 27/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

public class Environment {

    // External environment properties
    // -------------------------------
    
    // Debug mode activation
    public let isDebug: Bool
    
    // Messenger used to propagate interpreter message outside
    let messenger: Messenger?
    
    public typealias ScriptModuleHandler = (_ name: String) -> String?
    
    // Handler provided for getting external module scripts
    let getScriptForModule: ScriptModuleHandler?

    // Internal environment properties
    // -------------------------------
    
    // Global scope used to store loaded modules
    let modulesScope = Scope(parent: nil)

    public init(isDebug: Bool,
         messenger: Messenger?,
         getScriptForModule: ScriptModuleHandler?) {
        
        self.isDebug = isDebug
        self.messenger = messenger
        self.getScriptForModule = getScriptForModule
    }
    
}
