//
//  ModuleViewCell.swift
//  TestEditor
//
//  Created by poisson florent on 17/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

protocol ModuleViewCellDelegate: class {
    
    func userDidEditModuleName(in cell: ModuleViewCell)
    
}

class ModuleViewCell: UITableViewCell {

    weak var delegate: ModuleViewCellDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameTextField.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - State management
    
    func setName(_ name: String?) {
        nameTextField.text = name
    }
    
    func setLock(_ isLocked: Bool?) {
        let isLocked = isLocked ?? false
        lockImageView.isHidden = !isLocked
        editButton.isHidden = isLocked
    }
    
    private func enableNameEdition(_ isEnabled: Bool) {
        nameTextField.isEnabled = isEnabled
        nameTextField.backgroundColor = isEnabled ?
            UIColor(white: 0.95, alpha: 1) :
            .white
        DispatchQueue.main.async {
            if isEnabled {
                self.nameTextField.becomeFirstResponder()
            } else {
                self.nameTextField.resignFirstResponder()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func editButtonTapped(sender: UIButton) {
        enableNameEdition(true)
    }
    
    @IBAction func nameEditingDidEndOnExit(sender: UITextField) {
        // NOTE: implemented for passing also in nameEditingDidEnd(...)
    }
    
    @IBAction func nameEditingChanged(sender: UITextField) {
        sender.text = sender.text?.identifier.capitalized
    }
    
    @IBAction func nameEditingDidBegin(sender: UITextField) {
        // Select the name for edition
        if let name = sender.text {
            let extensionSuffix = "." + ModuleFile.extension
            var offset = name.count
            if name.hasSuffix(extensionSuffix) {
                offset -= extensionSuffix.count
            }
            sender.text = String(name[name.startIndex..<name.index(name.startIndex, offsetBy: offset)])
            sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument,
                                                        to: sender.endOfDocument)
        }
    }
    
    @IBAction func nameEditingDidEnd(sender: UITextField) {
        enableNameEdition(false)
        delegate?.userDidEditModuleName(in: self)
    }

}
