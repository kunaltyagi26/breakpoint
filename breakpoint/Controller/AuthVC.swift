//
//  AuthVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 25/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FacebookCore
import GoogleSignIn

class AuthVC: UIViewController {

    @IBOutlet weak var fbBtnView: UIView!
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self as! GIDSignInDelegate
        GIDSignIn.sharedInstance().uiDelegate = self as! GIDSignInUIDelegate
        
        //fbLoginBtn.delegate = self
        //fbLoginBtn.readPermissions = ["public_profile", "email"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fbButton = UIButton(frame: CGRect(x: 0, y: 0, width: fbBtnView.frame.width, height: fbBtnView.frame.height))
        fbButton.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        fbButton.setTitle("Login with FB", for: .normal)
        fbButton.addTarget(self, action: #selector(fbBtnPressed), for: .touchUpInside)
        fbBtnView.addSubview(fbButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if Auth.auth().currentUser != nil {
            dismissDetail()
        }
        
        
    }
    
    @objc func fbBtnPressed() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                let credential = FacebookAuthProvider.credential(withAccessToken: String(describing: AccessToken.current))
                Auth.auth().signIn(with: credential) { (user, error) in
                    guard let user = user else {
                        return
                    }
                    let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: accessToken, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: .defaultVersion)
                    let request = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
                    request.start { (response, result) in
                        switch result {
                        case .success(let value):
                            guard let dict = value.dictionaryValue as? NSDictionary else { return }
                            let email = dict["email"]
                            let userData = ["provider": "Facebook", "email": email]
                            
                            /*DataService.instance.checkForNewUser(uid: user.uid, completion: { (isNewUser) in
                                if isNewUser {
                                    DataService.instance.createDBUser(uid: user.uid, userData: userData)
                                    print("User created.")
                                    guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                                    self.present(personalDetailsVC, animated: true, completion: nil)
                                }
                                else {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })*/
                            guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                            self.present(personalDetailsVC, animated: true, completion: nil)
                        case .failed(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func emailBtnPressed(_ sender: Any) {
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
        presentDetail(viewControllerToPresent: loginVC)
    }
    
    @IBAction func googleBtnPressed(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }
}

extension AuthVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (user, error) in
                guard let user = user else {
                    return
                }
                let userData = ["provider": "Google", "email": user.email]
                DataService.instance.checkForNewUser(uid: user.uid, completion: { (isNewUser) in
                    if isNewUser {
                        DataService.instance.createDBUser(uid: user.uid, userData: userData)
                        print("User created.")
                        guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                        self.present(personalDetailsVC, animated: true, completion: nil)
                    }
                    else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
}

extension AuthVC: GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}
