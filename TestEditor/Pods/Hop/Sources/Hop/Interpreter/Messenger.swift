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
    
    public typealias MessageHandler = (_ sessionId: String?, _ message: Message) -> Void
    
    var sessionId: String?
    var handlers = [MessageType: [MessageHandler]]()
    
    // Notifications declaration
    static let messagePostingNotification = Notification.Name(rawValue: "com.Messenger.messagePostingNotification")
    static let messageInfoKey = "com.Messenger.messageInfoKey"
    
    public init(sessionId: String?) {
        self.sessionId = sessionId
        
        // Register for internal message posting notifications
        NotificationCenter.default.addObserver(forName: Messenger.messagePostingNotification,
                                               object: nil,
                                               queue: nil) {
                                                [weak self] (notification) in
                                                self?.dispatchMessage(from: notification)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func subscribe(to messageType: MessageType,
                          handler: @escaping MessageHandler) {
        
        if handlers[messageType] == nil {
            handlers[messageType] = [MessageHandler]()
        }
        
        handlers[messageType]?.append(handler)
    }
    
    private func dispatchMessage(from notification: Notification) {
        if let message = notification.userInfo?[Messenger.messageInfoKey] as? Message,
            let messageHandlers = handlers[message.type] {
            for messageHandler in messageHandlers {
                messageHandler(sessionId, message)
            }
        }
    }
    
    static func post(message: Message) {
        let userInfo: [String: Any] = [
            Messenger.messageInfoKey: message
        ]
        let notification = Notification(name: Messenger.messagePostingNotification,
                                        object: nil,
                                        userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
}
