//
//  FileManager+Extension.swift
//  TestEditor
//
//  Created by poisson florent on 11/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

extension FileManager {

    static var documentDirectoryUrl: URL {
        return `default`.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
}
