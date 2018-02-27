//
//  LoginVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 25/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView
import TKSubmitTransition
import Pastel
import TextFieldEffects

class LoginVC: UIViewController {

    @IBOutlet weak var emailTxt: JiroTextField!
    @IBOutlet weak var passwordTxt: InsetTextField!
    @IBOutlet weak var signInBtn: TKTransitionSubmitButton!
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var credentialsStackView: UIStackView!
    @IBOutlet weak var signInLbl: UILabel!
    @IBOutlet var loginView: PastelView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxt.delegate = self
        passwordTxt.delegate = self
        emailTxt.autocorrectionType = .no
        registerStackView.elementsMoveWithKeyboard()
        credentialsStackView.elementsMoveWithKeyboard()
        signInBtn.bindToKeyboard()
        screenTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginView.startPastelPoint = .bottomLeft
        loginView.endPastelPoint = .topRight
        loginView.setColors([UIColor(red: 98/255, green: 39/255, blue: 116/255, alpha: 1.0), UIColor(red: 197/255, green: 51/255, blue: 100/255, alpha: 1.0), UIColor(red: 113/255, green: 23/255, blue: 234/255, alpha: 1.0), UIColor(red: 234/255, green: 96/255, blue: 96/255, alpha: 1.0)])
        loginView.startAnimation()
        emailTxt.layer.cornerRadius = 10
        emailTxt.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        emailTxt.layer.borderWidth = 1.0
        passwordTxt.layer.cornerRadius = 10
        passwordTxt.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        passwordTxt.layer.borderWidth = 1.0
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        guard let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "registerVC") as? RegisterVC else { return }
        self.present(registerVC, animated: true, completion: nil)
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        self.signInBtn.startLoadingAnimation()
        if emailTxt.text != nil && passwordTxt.text != nil {
            AuthService.instance.loginUser(withEmail: emailTxt.text!, andPassword: passwordTxt.text!, completion: { (success, error) in
                if success {
                    self.signInBtn.startFinishAnimation(1, completion: {
                        self.performSegue(withIdentifier: "tabbedVC", sender: self)
                    })
                }
                else {
                    self.signInBtn.setOriginalState()
                    self.signInBtn.setTitle("Sign In", for: .normal)
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        else {
            self.signInBtn.setOriginalState()
            self.signInBtn.setTitle("Sign In", for: .normal)
            let alertController = UIAlertController(title: "Error", message: "Please enter your username and password.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func closePressed(_ sender: Any) {
        guard let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC else { return }
        self.present(authVC, animated: true, completion: nil)
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        textField.layer.borderWidth = 2.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textField.layer.borderWidth = 1.0
    }
}
