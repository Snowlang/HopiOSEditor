//
//  String+Extension.swift
//  TestEditor
//
//  Created by poisson florent on 11/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

extension String {

    var identifier: String {
        let value = folding(options: .diacriticInsensitive, locale: nil)
        var characters = Array(value)
        let characterSet = NSCharacterSet.alphanumerics
        for i in 0..<characters.count {
            if !characterSet.contains(characters[i].unicodeScalars.first!) {
                characters[i] = "_"
            }
        }
        return String(characters)
    }
    
}
