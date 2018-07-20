//
//  Type.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct Type {
    
    var name: String
    var hashId: Int
    
    init(name: String) {
        self.name = name
        self.hashId = name.hashValue
    }
    
    init(typeExpr: Evaluable) {
        var name: String!
        do {
            name = try Type.getName(from: typeExpr)
        } catch let error {
            assertionFailure("Error: failed to get transcript from identifier chain, with error: \(error)!")
        }
        self.init(name: name)
    }
    
    private static func getName(from typeExpr: Evaluable) throws -> String {
        // NOTE: `typeExpr` is a chain of identifier separated by dots
        
        if let identifierExpr = typeExpr as? IdentifierExpr {
            return identifierExpr.name
        }
        
        if let binOpExpr = typeExpr as? BinaryOperatorExpr {
            return try getDotBinOpTranscript(binOpExpr)
        }
        
        throw TypeTranscriptError.unknownExpression
    }
    
    enum TypeTranscriptError: Error {
        case dotOperatorNotFound
        case rhsIdentifierNotFound
        case unknownExpression
    }
    
    private static func getDotBinOpTranscript(_ binOpExpr: BinaryOperatorExpr) throws -> String {
        if binOpExpr.binOp == .dot {
            if let rhsIdentifierExpr = binOpExpr.rhs as? IdentifierExpr {
                if let lshIdentifierExpr = binOpExpr.lhs as? IdentifierExpr {
                    return lshIdentifierExpr.name + "." + rhsIdentifierExpr.name
                } else if let lhsDotBinOpExpr = binOpExpr.lhs as? BinaryOperatorExpr {
                    return try getDotBinOpTranscript(lhsDotBinOpExpr) + "." + rhsIdentifierExpr.name
                } else {
                    throw TypeTranscriptError.unknownExpression
                }
            } else {
                throw TypeTranscriptError.rhsIdentifierNotFound
            }
        } else {
            throw TypeTranscriptError.dotOperatorNotFound
        }
    }
    
}

extension Type: Equatable {
    
    static func == (lhs: Type, rhs: Type) -> Bool {
        return lhs.hashId == rhs.hashId
    }
    
    static func != (lhs: Type, rhs: Type) -> Bool {
        return lhs.hashId != rhs.hashId
    }
    
}

// MARK: - Basic types
extension Type {
    
    static let void     = Type(name: "Void")
    static let integer  = Type(name: "Int")
    static let real     = Type(name: "Real")
    static let boolean  = Type(name: "Bool")
    static let string   = Type(name: "String")
    static let any      = Type(name: "Any")
    
    static let basicTypes: [Type] = [
        .void, .integer, .real, .boolean, .string, .any
    ]
    
    static let basicTypeHashIds: Set<Int> = Set(basicTypes.map { $0.hashId })

}

// MARK: - Helpers
extension Type {
    
    static func type(of value: Any) -> Type {
        if value is Int { return .integer }
        if value is Double { return .real }
        if value is Bool { return .boolean }
        if value is String { return .string }
        if let instance = value as? Instance {
            return instance.class.type
        }
        return .any
    }
    
}
