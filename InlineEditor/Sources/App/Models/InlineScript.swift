//
//  InlineScript.swift
//  App
//
//  Created by Iman Zarrabian on 20/07/2018.
//

import Foundation
import Vapor

final class InlineScript: Codable {
    var script: String

    init(script: String) {
        self.script = script
    }
}

extension InlineScript: Content {}
