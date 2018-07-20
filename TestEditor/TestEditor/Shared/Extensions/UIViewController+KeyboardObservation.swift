//
//  UIViewController+KeyboadObservation.swift
//  Jaccede
//
//  Created by Eddy Claessens on 14/04/16.
//  Copyright © 2016 One More Thing Studio. All rights reserved.
//

import UIKit

protocol KeyboardObserverDelegate {
    func keyboardWillMove(to height: CGFloat, with duration: TimeInterval)
    func keyboardDidHide()
}

extension UIViewController {
    
    func startObservingKeyboard() // call it from viewWillAppear
    {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func stopObservingKeyboard() // call it from viewWillDissappear
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide,
                                                  object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            (self as! KeyboardObserverDelegate).keyboardWillMove(to: keyboardSize.height, with: keyboardDuration)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            (self as! KeyboardObserverDelegate).keyboardWillMove(to: 0, with: keyboardDuration)
        }
    }

    @objc func keyboardDidHide(notification: NSNotification) {
        (self as! KeyboardObserverDelegate).keyboardDidHide()
    }
}
