//
//  PackageCreationFormController.swift
//  TestEditor
//
//  Created by poisson florent on 11/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

protocol PackageCreationFormControllerDelegate: class {
    
    func userDidFillPackageForm(name: String,
                                title: String?,
                                description: String?,
                                in repository: PackageRepository)

}

class PackageCreationFormController: UIViewController {

    weak var delegate: PackageCreationFormControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shadowedView: UIView!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var packageNameTextField: UITextField!
    @IBOutlet weak var packageTitleLabel: UILabel!
    @IBOutlet weak var packageTitleTextField: UITextField!
    @IBOutlet weak var packageDescriptionLabel: UILabel!
    @IBOutlet weak var packageDescriptionTextView: UITextView!
    @IBOutlet var buttons: [UIButton]!
    
    var repository: PackageRepository!
    
    private var packageName: String?
    private var packageTitle: String?
    private var packageDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        customize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startObservingKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObservingKeyboard()
    }
    
    private func customize() {
        shadowedView.layer.shadowColor = UIColor(white: 0, alpha: 0.5).cgColor
        shadowedView.layer.shadowRadius = 4
        shadowedView.layer.shadowOpacity = 0.2
        shadowedView.layer.shadowOffset = CGSize(width: 0, height: 3)
        formView.layer.cornerRadius = 8

        buttons.forEach {
            $0.layer.shadowColor = UIColor(white: 0, alpha: 0.5).cgColor
            $0.layer.shadowRadius = 4
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowOffset = CGSize(width: 0, height: 3)
        }
        
        // Handle resign when user tap outside textfields
        let endEditingTapGesture = UITapGestureRecognizer(target: self,
                                                          action: #selector(endEditingTap(tapGesture:)))
        view.addGestureRecognizer(endEditingTapGesture)
        
        // Localize
        titleLabel.text = NSLocalizedString("New package", comment: "").uppercased()
        packageNameLabel.text = NSLocalizedString("Name", comment: "")
        packageTitleLabel.text = NSLocalizedString("Title", comment: "")
        packageDescriptionLabel.text = NSLocalizedString("Description", comment: "")
    }

    // MARK: - State management
    
    private func displayPackageNameAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Package name is mandatory!", comment: ""),
            message: nil,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                     style: .cancel,
                                     handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController,
                animated: true,
                completion: nil)
    }
    
    fileprivate func scrollToView(_ view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let bounds = view.bounds.offsetBy(dx: 0, dy: 24)
            self.scrollView.scrollRectToVisible(view.convert(bounds, to: self.scrollView),
                                                animated: true)
        }
    }
    
    @objc func endEditingTap(tapGesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismiss(animated: true,
                completion: nil)
    }
    
    @IBAction func okButtonTapped(sender: UIButton) {
        guard let packageName = packageName,
            !packageName.isEmpty else {
            displayPackageNameAlert()
            return
        }
        
        delegate?.userDidFillPackageForm(name: packageName,
                                         title: packageTitle,
                                         description: packageDescription,
                                         in: repository)
        
        dismiss(animated: true,
                completion: nil)
    }
    
    @IBAction func packageNameEndsOnExit(sender: UITextField) {
        packageTitleTextField.becomeFirstResponder()
    }
    
    @IBAction func packageNameDidChange(sender: UITextField) {
        packageName = sender.text?.identifier.capitalized
        sender.text = packageName
    }

    @IBAction func packageTitleEndsOnExit(sender: UITextField) {
        packageDescriptionTextView.becomeFirstResponder()
    }
    
    @IBAction func packageTitleDidChange(sender: UITextField) {
        packageTitle = sender.text
    }
    
}

// MARK: - KeyboardObserverDelegate
extension PackageCreationFormController: KeyboardObserverDelegate {
    
    func keyboardWillMove(to height: CGFloat, with duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            let contentInsets = UIEdgeInsets(top: 0,
                                             left: 0,
                                             bottom: height,
                                             right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }

        var targetedView: UIView!
        if self.packageNameTextField.isFirstResponder {
            targetedView = self.packageNameTextField
        } else if self.packageTitleTextField.isFirstResponder {
            targetedView = packageTitleTextField
        } else if self.packageDescriptionTextView.isFirstResponder {
            targetedView = buttons[0]
        }
        scrollToView(targetedView)
    }

    func keyboardDidHide() {
        // ...
    }

}

// MARK: - UITextViewDelegate
extension PackageCreationFormController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        packageDescription = (textView.text != nil && !textView.text!.isEmpty ?
                textView.text :
                nil)
    }
    
}
