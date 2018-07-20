//
//  URL+extension.swift
//  TestEditor
//
//  Created by poisson florent on 11/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

extension URL {

    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        if isFileURL,
            FileManager.default.fileExists(atPath: path,
                                          isDirectory: &isDirectory),
            isDirectory.boolValue {
            return true
        }
        return false
    }
    
}
