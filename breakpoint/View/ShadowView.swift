//
//  ShadowView.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 25/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

//@IBDesignable
class ShadowView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    
    /*override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }*/
    
    func setUpView() {
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 10
        self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
