//
//  UIViewExt.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 28/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

extension UIView{
    func bindToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        self.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    func elementsMoveWithKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowWithElements(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideWithElements(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShowWithElements(notification: NSNotification){
        //let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        self.transform = CGAffineTransform(translationX: 0, y: -40)
    }
    
    @objc func keyboardWillHideWithElements(notification: NSNotification){
        self.transform = CGAffineTransform(translationX: 0, y: 0)
    }
}

