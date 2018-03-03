//
//  RegisterVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 13/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView
import Pastel
import TKSubmitTransition

class RegisterVC: UIViewController {

    @IBOutlet weak var emailTxt: InsetTextField!
    @IBOutlet weak var passwordTxt: InsetTextField!
    @IBOutlet weak var credentialsStackView: UIStackView!
    @IBOutlet weak var registerView: PastelView!
    //@IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var nextBtn: TKTransitionSubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxt.delegate = self
        passwordTxt.delegate = self
        emailTxt.autocorrectionType = .no
        credentialsStackView.elementsMoveWithKeyboard()
        nextBtn.bindToKeyboard()
        screenTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerView.startPastelPoint = .bottomLeft
        registerView.endPastelPoint = .topRight
        registerView.setColors([UIColor(red: 98/255, green: 39/255, blue: 116/255, alpha: 1.0), UIColor(red: 197/255, green: 51/255, blue: 100/255, alpha: 1.0), UIColor(red: 113/255, green: 23/255, blue: 234/255, alpha: 1.0), UIColor(red: 234/255, green: 96/255, blue: 96/255, alpha: 1.0)])
        registerView.startAnimation()
        emailTxt.layer.cornerRadius = 10
        emailTxt.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        emailTxt.layer.borderWidth = 1.0
        passwordTxt.layer.cornerRadius = 10
        passwordTxt.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        passwordTxt.layer.borderWidth = 1.0
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
    
    @IBAction func nextPressed(_ sender: Any) {
        self.nextBtn.startLoadingAnimation()
        if emailTxt.text != nil && passwordTxt.text != nil {
            AuthService.instance.registerUser(withEmail: self.emailTxt.text!, andPassword: self.passwordTxt.text!, completion: { (success, error) in
                if error == nil {
                    AuthService.instance.loginUser(withEmail: self.emailTxt.text!, andPassword: self.passwordTxt.text!, completion: { (success, nil) in
                        if success {
                            DataService.instance.checkForNewUser(uid: (Auth.auth().currentUser?.uid)!, completion: { isNewUser in
                                if isNewUser {
                                    let userData = ["provider": Auth.auth().currentUser?.providerID, "email": self.emailTxt.text!]
                                    DataService.instance.createDBUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData)
                                    guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                                    //personalDetailsVC.getCredentials(email: self.emailTxt.text!, password: self.passwordTxt.text!)
                                    self.nextBtn.startFinishAnimation(1, completion: {
                                        self.present(personalDetailsVC, animated: true, completion: nil)
                                    })
                                }
                                else {
                                    self.nextBtn.setOriginalState()
                                    self.nextBtn.setTitle("Next", for: .normal)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        }
                    })
                }
                else {
                    self.nextBtn.setOriginalState()
                    self.nextBtn.setTitle("NEXT", for: .normal)
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        else {
            self.nextBtn.setOriginalState()
            self.nextBtn.setTitle("Next", for: .normal)
            let alertController = UIAlertController(title: "Error", message: "Please enter your username and password", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        textField.layer.borderWidth = 2.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textField.layer.borderWidth = 1.0
    }
}
