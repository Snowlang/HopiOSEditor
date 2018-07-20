//
//  PackageViewCell.swift
//  TestEditor
//
//  Created by poisson florent on 11/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

class PackageViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var lockImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - State management
    
    func setName(_ name: String?) {
        nameLabel.text = name
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    func setLock(_ isLocked: Bool?) {
        lockImageView.isHidden = !(isLocked ?? false)
    }

}
