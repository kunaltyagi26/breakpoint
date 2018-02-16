//
//  LoginVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 25/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var emailTxt: InsetTextField!
    @IBOutlet weak var passwordTxt: InsetTextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var credentialsStackView: UIStackView!
    @IBOutlet weak var signInLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxt.delegate = self
        passwordTxt.delegate = self
        emailTxt.autocorrectionType = .no
        signInView.bindToKeyboard()
        registerStackView.elementsMoveWithKeyboard()
        credentialsStackView.elementsMoveWithKeyboard()
        screenTap()
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        guard let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "registerVC") as? RegisterVC else { return }
        self.present(registerVC, animated: true, completion: nil)
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        if emailTxt.text != nil && passwordTxt.text != nil {
            AuthService.instance.loginUser(withEmail: emailTxt.text!, andPassword: passwordTxt.text!, completion: { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            })
        }
        else {
            let alertController = UIAlertController(title: "Error", message: "Please enter your username and password", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func screenTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        view.addGestureRecognizer(tap)
    }
    
    @objc func screenTapAction(){
        view.endEditing(true)
    }
}

extension LoginVC: UITextFieldDelegate {
    
}
