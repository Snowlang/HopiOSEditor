//
//  ModuleCreationFormController.swift
//  TestEditor
//
//  Created by poisson florent on 19/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

protocol ModuleCreationFormControllerDelegate: class {
    
    func userDidFillModuleForm(name: String)
    
}

class ModuleCreationFormController: UIViewController {
    
    weak var delegate: ModuleCreationFormControllerDelegate?
    
    @IBOutlet weak var containerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var shadowedView: UIView!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moduleNameLabel: UILabel!
    @IBOutlet weak var moduleNameTextField: UITextField!
    @IBOutlet var buttons: [UIButton]!
    
    private var moduleName: String?
    
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
        
        moduleNameTextField.becomeFirstResponder()
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
        titleLabel.text = NSLocalizedString("New module", comment: "").uppercased()
        moduleNameLabel.text = NSLocalizedString("Name", comment: "")
    }
    
    // MARK: - State management
    
    private func displayModuleNameAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Module name is mandatory!", comment: ""),
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
        
    @objc func endEditingTap(tapGesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismiss(animated: true,
                completion: nil)
    }
    
    @IBAction func okButtonTapped(sender: UIButton) {
        guard let moduleName = moduleName,
            !moduleName.isEmpty else {
                displayModuleNameAlert()
                return
        }
        
        delegate?.userDidFillModuleForm(name: moduleName)
        
        dismiss(animated: true,
                completion: nil)
    }
    
    @IBAction func moduleNameEndsOnExit(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func moduleNameDidChange(sender: UITextField) {
        moduleName = sender.text?.identifier.capitalized
        sender.text = moduleName
    }
    
}

// MARK: - KeyboardObserverDelegate
extension ModuleCreationFormController: KeyboardObserverDelegate {
    
    func keyboardWillMove(to height: CGFloat, with duration: TimeInterval) {
        self.containerViewBottom.constant = height
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardDidHide() {
        // ...
    }
    
}
