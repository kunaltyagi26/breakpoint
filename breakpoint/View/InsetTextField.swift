//
//  InsetTextField.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 25/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

//@IBDesignable
class InsetTextField: UITextField {
    private var padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func setUpView() {
        let placeholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6187600493, green: 0.836951673, blue: 0.3785187602, alpha: 1)])
        self.attributedPlaceholder = placeholder
    }
    
    /*override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }*/
}
