//
//  PackageDirectory.swift
//  TestEditor
//
//  Created by poisson florent on 10/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit



enum PackageInfoKey: String {
    case title          // Value of type String
    case description    // Value of type String
    case isImmutable    // Value of type Bool
}

struct PackageDirectory {
    
    let url: URL
    let info: [String: Any]?

    var name: String {
        return url.lastPathComponent
    }
    
    var title: String? {
        return getInfoValue(for: .title) as? String
    }
    
    var isImmutable: Bool {
        return (getInfoValue(for: .isImmutable) as? Bool) ?? false
    }
    
    init(url: URL, info: [String: Any]?) {
        self.url = url
        self.info = info
    }
    
    init(name: String, repository: PackageRepository) {
        let url = repository
            .url
            .appendingPathComponent(name, isDirectory: true)
        
        self.init(url: url, info: nil)
    }
    
    // MARK: - Static methods
    
    static func getPackages(at directoryUrl: URL) throws -> [PackageDirectory] {
        guard directoryUrl.isDirectory else {
            print("Error: url does not point to a directory!")
            throw EditorError.urlError
        }

        let packageUrls = try FileManager.default.contentsOfDirectory(at: directoryUrl,
                                                                      includingPropertiesForKeys: nil,
                                                                      options: .skipsHiddenFiles)
        var packages = [PackageDirectory]()
        
        for packageUrl in packageUrls {
            if !packageUrl.isDirectory {
                continue
            }

            let packageInfo = getInfo(for: packageUrl)
            
            let package = PackageDirectory(url: packageUrl,
                                           info: packageInfo)
            packages.append(package)
        }
        
        packages.sort { (package1, package2) -> Bool in
            return package1.name < package2.name
        }
        
        return packages
    }
    
    static let infoFileName = "Package.json"
    
    static func getInfo(for packageUrl: URL) -> [String: Any]? {
        let infoFileUrl = packageUrl.appendingPathComponent(infoFileName)
        guard let infoData = try? Data(contentsOf: infoFileUrl) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: infoData, options: .allowFragments)) as? [String: Any]
    }
    
    static func delete(packageDirectory: PackageDirectory ) throws {
        let fileManager = FileManager.default
        // Remove all files
        let fileUrls = try fileManager.contentsOfDirectory(at: packageDirectory.url,
                                                           includingPropertiesForKeys: nil,
                                                           options: .skipsHiddenFiles)
        
        for fileUrl in fileUrls {
            try fileManager.removeItem(at: fileUrl)
        }
        
        // Remove directory
        try fileManager.removeItem(at: packageDirectory.url)
    }
    
    // MARK: - State management
    
    func getInfoValue(for key: PackageInfoKey) -> Any? {
        return info?[key.rawValue]
    }
    
    mutating func updatePackage(title: String?,
                                description: String?,
                                isImmutable: Bool) throws {
        // Directory creation
        var info = [String: Any]()
        info[PackageInfoKey.title.rawValue] = title
        info[PackageInfoKey.description.rawValue] = description
        info[PackageInfoKey.isImmutable.rawValue] = isImmutable
        
        let package = PackageDirectory(url: url,
                                       info: info)
        try package.save()
        
        self = package
    }

    
    func save() throws {
        if !url.isFileURL {
            // Package url is not even one of a file!
            throw EditorError.urlError
        }
        
        // Create directory if needed
        let fileManager = FileManager.default
        
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: url.path,
                                  isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                // A file already exists
                throw EditorError.urlCollision
            }
        } else {
            // Create the directory
            try fileManager.createDirectory(at: url,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        }
        
        // Save info file if needed
        if let info = info,
            !info.isEmpty {
            let infoData = try JSONSerialization.data(withJSONObject: info)
            let infoFileUrl = url
                .appendingPathComponent("package")
                .appendingPathExtension("json")
            try infoData.write(to: infoFileUrl)
        }
    }

}
