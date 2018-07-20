//
//  PackagesSectionHeaderView.swift
//  TestEditor
//
//  Created by poisson florent on 11/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

protocol PackagesSectionHeaderViewDelegate: class {
    
    func addButtonTapped(for repository: PackageRepository)
    
}

class PackagesSectionHeaderView: UIView {
    
    weak var delegate: PackagesSectionHeaderViewDelegate?
    
    private var label: UILabel!
    private var labelTrailing: NSLayoutConstraint!
    private var addButton: UIButton!
    
    var repository: PackageRepository! {
        didSet {
            setTitle(repository.title)
            labelTrailing.constant = repository.isImmutable ? 16 : 16 + 8 + addButton.bounds.width
            addButton.isHidden = repository.isImmutable
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        customize()
    }
    
    private func customize() {
        var constraints = [NSLayoutConstraint]()
        
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        // Add button setup
        let adButtonSize: CGFloat = 33
        addButton = UIButton(type: .custom)
        addButton.setImage(#imageLiteral(resourceName: "add-button-icon"), for: .normal)
        addButton.addTarget(self,
                            action: #selector(addButtonTapped(sender:)),
                            for: .touchUpInside)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addButton)
        constraints.append(contentsOf: [
            addButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: adButtonSize),
            addButton.heightAnchor.constraint(equalToConstant: adButtonSize)
            ])

        // Title label setup
        label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        labelTrailing = label.rightAnchor.constraint(equalTo: rightAnchor, constant: 16)
        constraints.append(contentsOf: [
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            labelTrailing,
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

        // Bottom separator
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(hexString: "#554400")
            .withAlphaComponent(0.4)

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        constraints.append(contentsOf: [
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - State management
    
    func setTitle(_ title: NSAttributedString?) {
        label.attributedText = title
    }

    // MARK: - Actions
    
    @objc func addButtonTapped(sender: UIButton) {
        delegate?.addButtonTapped(for: repository)
    }
    
}
