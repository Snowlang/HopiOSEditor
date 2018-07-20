//
//  PackageInfoController.swift
//  TestEditor
//
//  Created by poisson florent on 13/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

protocol PackageInfoControllerDelegate: class {
    
    func userDidUpdatePackageInfo(title: String?,
                                  description: String?,
                                  isImmutable: Bool)
    
}

class PackageInfoController: UIViewController {

    weak var delegate: PackageInfoControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var packageTitleLabel: UILabel!
    @IBOutlet weak var packageTitleTextField: UITextField!
    @IBOutlet weak var packageDescriptionLabel: UILabel!
    @IBOutlet weak var packageDescriptionTextView: UITextView!
    @IBOutlet weak var immutabilityLabel: UILabel!
    @IBOutlet weak var immutabilitySwitch: UISwitch!

    var packageName: String?
    var packageTitle: String?
    var packageDescription: String?
    var packageImmutability: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func customize() {
        navigationItem.title = packageName
        packageTitleTextField.text = packageTitle
        packageDescriptionTextView.text = packageDescription
        immutabilitySwitch.isOn = packageImmutability

        // Localize
        packageTitleLabel.text = NSLocalizedString("Title", comment: "")
        packageDescriptionLabel.text = NSLocalizedString("Description", comment: "")
        immutabilityLabel.text = NSLocalizedString("Immutability", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func packageTitleEndsOnExit(sender: UITextField) {
        packageDescriptionTextView.becomeFirstResponder()
    }
    
    @IBAction func packageTitleDidChange(sender: UITextField) {
        packageTitle = sender.text
    }
    
    @IBAction func packageImmutabilityValueChanged(sender: UISwitch) {
        packageImmutability = sender.isOn
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismiss(animated: true,
                completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        delegate?.userDidUpdatePackageInfo(title: packageTitle,
                                           description: packageDescription,
                                           isImmutable: packageImmutability)
        dismiss(animated: true,
                completion: nil)
    }

}

// MARK: - UITextViewDelegate
extension PackageInfoController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        packageDescription = (textView.text != nil && !textView.text!.isEmpty ?
            textView.text :
            nil)
    }
    
}
