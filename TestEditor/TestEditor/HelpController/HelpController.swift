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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mdView = MarkdownView()
        mdView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mdView)
    
        NSLayoutConstraint.activate([
            mdView.topAnchor.constraint(equalTo: view.topAnchor),
            mdView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mdView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mdView.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
    
        let helpUrl = Bundle.main.url(forResource: "Help", withExtension: "md")!
        let help = try? String(contentsOf: helpUrl)
        
        mdView.load(markdown: help)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
