//
//  HelpController.swift
//  TestEditor
//
//  Created by poisson florent on 03/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit
import MarkdownView

class HelpController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let mdView = MarkdownView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMarkdownView()
        
        displayLanguageReference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupMarkdownView() {
        mdView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mdView)
        view.sendSubview(toBack: mdView)
        
        NSLayoutConstraint.activate([
            mdView.topAnchor.constraint(equalTo: view.topAnchor),
            mdView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mdView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mdView.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
    }
    
    // MARK: - State management
    
    private func getLanguageReference(completion: @escaping (_ languageReference: String?, _ error: Error?) -> Void) {

        let languageReferenceUrl = URL(string: Constants.Editor.languageReferenceUrl)!
        
        DispatchQueue.global(qos: .utility).async {
            var languageReference: String!
            var gettingError: Error!
            
            do {
                languageReference = try String(contentsOf: languageReferenceUrl,
                                               encoding: String.Encoding.utf8)
            } catch let error {
                print("Error: \(error)")
                gettingError = error
            }
            
            DispatchQueue.main.async {
                completion(languageReference, gettingError)
            }
        }
    }
    
    private func displayLanguageReference() {
        activityIndicator.startAnimating()
        
        getLanguageReference {
            [weak self] (languageReference, error) in
            
            self?.activityIndicator.stopAnimating()
            
            if let error = error {
                self?.displayError(title: NSLocalizedString("Can't get language reference...", comment: ""),
                                   message: error.localizedDescription)
            } else {
                self?.mdView.load(markdown: languageReference)
            }
        }
    }

    private func displayError(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                     style: .cancel,
                                     handler: nil)
        alertController.addAction(okAction)
        
        present(alertController,
                animated: true,
                completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
