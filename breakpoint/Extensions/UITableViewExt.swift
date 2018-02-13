//
//  UITableViewExt.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 04/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

extension UITableView {
    func tableViewBindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowBelowTable(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideBelowTable(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShowBelowTable(notification: NSNotification){
        let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        self.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
    }
    
    @objc func keyboardWillHideBelowTable(notification: NSNotification){
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
