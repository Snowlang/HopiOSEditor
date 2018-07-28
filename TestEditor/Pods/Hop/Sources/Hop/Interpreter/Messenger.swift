//
//  Messenger.swift
//  Hop iOS
//
//  Created by poisson florent on 26/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

public enum MessageType {
    case stdout
}

public struct Message {
    
    let type: MessageType
    public let identifier: String?
    public let data: Any
    
}

public class Messenger {
    
    public typealias MessageHandler = (_ message: Message) -> Void
    
    var handlers = [MessageType: [MessageHandler]]()

    public init() {}
    
    public func subscribe(to messageType: MessageType,
                          handler: @escaping MessageHandler) {
        
        if handlers[messageType] == nil {
            handlers[messageType] = [MessageHandler]()
        }
        
        handlers[messageType]?.append(handler)
    }

    func post(message: Message) {
        if let messageHandlers = handlers[message.type] {
            for messageHandler in messageHandlers {
                messageHandler(message)
            }
        }
    }
    
}
