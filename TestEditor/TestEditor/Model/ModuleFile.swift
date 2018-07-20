//
//  ModuleFile.swift
//  TestEditor
//
//  Created by poisson florent on 10/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

struct ModuleFile {
    
    static let `extension` = "hop"
    
    let packageDirectory: PackageDirectory
    let name: String

    var url: URL {
        return packageDirectory
            .url
            .appendingPathComponent(name)
            .appendingPathExtension(ModuleFile.extension)
    }
    
    func getScript() throws -> Script {
        let string = try String(contentsOf: url)
        return Script(string: string)
    }
    
    // MARK: - Static methods
    
    static func getModules(of packageDirectory: PackageDirectory) throws -> [ModuleFile] {
        let moduleUrls = try FileManager.default.contentsOfDirectory(at: packageDirectory.url,
                                                                     includingPropertiesForKeys: nil,
                                                                     options: .skipsHiddenFiles)
        var modules = [ModuleFile]()
        
        for moduleUrl in moduleUrls {
            if !moduleUrl.isFileURL {
                continue
            }
            
            // Check for file extension
            print("moduleUrl = \(moduleUrl.path)")
            if moduleUrl.pathExtension != ModuleFile.extension {
                continue
            }
            
            let name = moduleUrl
                .deletingPathExtension()
                .lastPathComponent
            let module = ModuleFile(packageDirectory: packageDirectory,
                                    name: name)
            
            modules.append(module)
        }
        
        modules.sort { (module1, module2) -> Bool in
            return module1.name < module2.name
        }
        
        return modules
    }

    mutating func rename(to name: String) throws {
        if name != self.name {
            let newUrl = packageDirectory
                .url
                .appendingPathComponent(name)
                .appendingPathExtension(ModuleFile.extension)
            
            try FileManager
                .default
                .moveItem(at: url, to: newUrl)

            let moduleFile = ModuleFile(packageDirectory: packageDirectory,
                                    name: name)
            self = moduleFile
        }
    }
    
    mutating func save(script: Script) throws {
        try script.string.write(to: url,
                                atomically: true,
                                encoding: String.Encoding.utf8)
    }

}
