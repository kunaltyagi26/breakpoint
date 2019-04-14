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
import NVActivityIndicatorView
import Pastel

class AuthVC: UIViewController {

    @IBOutlet weak var fbBtnView: UIView!
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    @IBOutlet var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet var authView: PastelView!
    
    var overlay: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self as GIDSignInDelegate
        GIDSignIn.sharedInstance().uiDelegate = self as GIDSignInUIDelegate
        overlay = UIView(frame: view.frame)
        overlay!.backgroundColor = UIColor.black
        overlay!.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authView.startPastelPoint = .bottomLeft
        authView.endPastelPoint = .topRight
        authView.setColors([UIColor(red: 98/255, green: 39/255, blue: 116/255, alpha: 1.0), UIColor(red: 197/255, green: 51/255, blue: 100/255, alpha: 1.0), UIColor(red: 113/255, green: 23/255, blue: 234/255, alpha: 1.0), UIColor(red: 234/255, green: 96/255, blue: 96/255, alpha: 1.0)])
        authView.startAnimation()
        let fbButton = UIButton(frame: CGRect(x: 0, y: 0, width: fbBtnView.frame.width, height: fbBtnView.frame.height))
        fbButton.backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.4039215686, blue: 0.6784313725, alpha: 1)
        fbButton.setTitle("LOGIN WITH FB", for: .normal)
        fbButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 17)
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
        overlay!.alpha = 0.5
        view.addSubview(overlay!)
        activityIndicatorView.bringSubview(toFront: overlay!)
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                let credential = FacebookAuthProvider.credential(withAccessToken: String(describing: accessToken.authenticationToken))
                print(AccessToken.current?.authenticationToken)
                print(accessToken.authenticationToken)
                Auth.auth().signIn(with: credential) { (user, error) in
                  print(error)
                    let request = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
                    request.start { (response, result) in
                        switch result {
                        case .success(let value):
                            guard let dict = value.dictionaryValue as? NSDictionary else { return }
                            let email = dict["email"]
                            let userData = ["provider": "Facebook", "email": email]
                            print((AccessToken.current?.userId)!)
                            DataService.instance.checkForNewUser(uid: (Auth.auth().currentUser?.uid)!, completion: { (isNewUser) in
                                print(isNewUser)
                                if isNewUser {
                                    DataService.instance.createDBUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData)
                                    print("User created.")
                                    guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                                    self.activityIndicatorView.stopAnimating()
                                   self.dismiss(animated: true, completion: nil)
                                }
                                else {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        case .failed(let error):
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.isHidden = true
                            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                            alertController.addAction(alertAction)
                            self.present(alertController, animated: true, completion: nil)
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
        overlay!.alpha = 0.5
        view.addSubview(overlay!)
        self.view.bringSubview(toFront: self.activityIndicatorView)
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        if error == nil {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (user, error) in
                guard let user = user else { return }
                let userData = ["provider": "Google", "email": user.email]
                DataService.instance.checkForNewUser(uid: user.uid, completion: { (isNewUser) in
                    if isNewUser {
                        DataService.instance.createDBUser(uid: user.uid, userData: userData)
                        print("User created.")
                        guard let personalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "personalDetailsVC") as? PersonalDetailsVC else { return }
                        self.overlay!.alpha = 0.8
                        self.overlay!.removeFromSuperview()
                        self.activityIndicatorView.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
        else {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
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
