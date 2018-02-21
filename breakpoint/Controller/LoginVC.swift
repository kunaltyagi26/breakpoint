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

class LoginVC: UIViewController {

    @IBOutlet weak var emailTxt: InsetTextField!
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
        signInBtn.elementsMoveWithKeyboard()
        screenTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #colorLiteral(red: 0.3960784314, green: 0.4745098039, blue: 0.6078431373, alpha: 1)
        loginView.startPastelPoint = .bottomLeft
        loginView.endPastelPoint = .topRight
        loginView.setColors([UIColor(red: 98/255, green: 39/255, blue: 116/255, alpha: 1.0), UIColor(red: 197/255, green: 51/255, blue: 100/255, alpha: 1.0), UIColor(red: 113/255, green: 23/255, blue: 234/255, alpha: 1.0), UIColor(red: 234/255, green: 96/255, blue: 96/255, alpha: 1.0)])
        loginView.startAnimation()
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
                        //self.dismiss(animated: true, completion: nil)
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
