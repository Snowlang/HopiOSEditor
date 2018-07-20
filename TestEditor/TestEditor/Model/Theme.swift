//
//  Theme.swift
//  TestEditor
//
//  Created by poisson florent on 04/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit
import DynamicColor

/**
 
 Editor theming
 
 */
struct Theme {

    var font: UIFont
    var backgroundColor: UIColor
    var textColor: UIColor
    var commentColor: UIColor
    var keywordsColor: UIColor
    var typeColor: UIColor
    var functionDeclarationColor: UIColor
    var functionCallColor: UIColor
    var accessedMembers: UIColor
    var stringColor: UIColor
    var numberColor: UIColor
    var operatorColor: UIColor
    var selectedLineNumberColor: UIColor
    var defaultLineNumberColor: UIColor

    static let dark = Theme(font: UIFont(name: "ArialMT", size: 15)!,
                            backgroundColor: UIColor(hexString: "#1E2028"),
                            textColor: .white,
                            commentColor: UIColor(hexString: "#41B645"),
                            keywordsColor: UIColor(hexString: "#B21889"),
                            typeColor: UIColor(hexString: "#00A0BE"),
                            functionDeclarationColor: UIColor(hexString: "#83C057"),
                            functionCallColor: UIColor(hexString: "#00A0BE"),
                            accessedMembers: UIColor(hexString: "#00A0BE"),
                            stringColor: UIColor(hexString: "#E7AF1F"),
                            numberColor: UIColor(hexString: "#786DC4"),
                            operatorColor: UIColor(hexString: "#E1004F"),
                            selectedLineNumberColor: UIColor(white: 1, alpha: 1),
                            defaultLineNumberColor: UIColor(white: 0.55, alpha: 1))

}
