//
//  RegisterVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 13/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {

    @IBOutlet weak var emailTxt: InsetTextField!
    @IBOutlet weak var passwordTxt: InsetTextField!
    @IBOutlet weak var credentialsStackView: UIStackView!
    @IBOutlet weak var registerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxt.autocorrectionType = .no
        credentialsStackView.elementsMoveWithKeyboard()
        registerView.bindToKeyboard()
        screenTap()
    }

    func screenTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        view.addGestureRecognizer(tap)
    }
    
    @objc func screenTapAction(){
        view.endEditing(true)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        if emailTxt.text != nil && passwordTxt.text != nil {
            AuthService.instance.registerUser(withEmail: self.emailTxt.text!, andPassword: self.passwordTxt.text!, completion: { (success, error) in
                if error == nil {
                    DataService.instance.checkForNewUser(uid: (Auth.auth().currentUser?.uid)!, completion: { isNewUser in
                        if isNewUser {
                            guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                            personalDetailsVC.getCredentials(email: self.emailTxt.text!, password: self.passwordTxt.text!)
                            self.present(personalDetailsVC, animated: true, completion: nil)
                        }
                        else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                    print("Successfully registered user.")
                }
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
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
}
