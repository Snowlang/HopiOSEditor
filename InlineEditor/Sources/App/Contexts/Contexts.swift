//
//  Contexts.swift
//  App
//
//  Created by Iman Zarrabian on 20/07/2018.
//

import Foundation


struct EditorContext: Encodable {
    let title: String
}

struct EvaluationContext: Encodable {
    let title: String
    let script: String
    let isResult = true
    let executionResult: String
}
