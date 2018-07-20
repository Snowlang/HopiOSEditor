//
//  PackageRepository.swift
//  TestEditor
//
//  Created by poisson florent on 11/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit
import SwiftyAttributes

enum PackageRepository: Int {
    
    case applications
    case libraries
    case tutorials
    
    static let count = 3
    
    var url: URL {
        switch self {
        case .applications:
            return FileManager
                .documentDirectoryUrl
                .appendingPathComponent("Applications")
            
        case .libraries:
            return FileManager
                .documentDirectoryUrl
                .appendingPathComponent("Libraries")
            
        case .tutorials:
            return Bundle
                .main
                .bundleURL
                .appendingPathComponent("Tutorials", isDirectory: true)
        }
    }
    
    var title: NSAttributedString {
        let iconImage: UIImage!
        let title: String!
        
        switch self {
        case .applications:
            iconImage = #imageLiteral(resourceName: "directory-icon")
            title = NSLocalizedString("Applications", comment: "")
            
        case .libraries:
            iconImage = #imageLiteral(resourceName: "library-icon")
            title = NSLocalizedString("Libraries", comment: "")
            
        case .tutorials:
            iconImage = #imageLiteral(resourceName: "tutorial-icon")
            title = NSLocalizedString("Tutorials", comment: "")
        }
        
        let attachment = NSTextAttachment()
        attachment.image = iconImage
        attachment.bounds = CGRect(x: 0, y: -8, width: iconImage.size.width/2, height: iconImage.size.height/2)
        return NSAttributedString(attachment: attachment)
            + "   ".attributedString
            + title.uppercased().attributedString
    }
    
    var isImmutable: Bool {
        switch self {
        case .tutorials:
            return true
        default:
            return false
        }
    }
    
}
