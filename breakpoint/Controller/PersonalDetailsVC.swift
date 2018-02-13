//
//  PersonalDetailsVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 10/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase

class PersonalDetailsVC: UIViewController {

    @IBOutlet weak var nameTxt: InsetTextField!
    @IBOutlet weak var phoneTxt: InsetTextField!
    
    var email: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func getCredentials(email: String, password: String) {
        self.email = email
        self.password = password
    }

    @IBAction func backPressed(_ sender: Any) {
        let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
        self.present(authVC!, animated: true, completion: nil)
    }
    
    @IBAction func NextPressed(_ sender: Any) {
        AuthService.instance.loginUser(withEmail: self.email!, andPassword: password!, completion: { (success, nil) in
            if success {
                let userData = ["provider": Auth.auth().currentUser?.providerID, "email": Auth.auth().currentUser?.email, "name": self.nameTxt.text!, "number": self.phoneTxt.text!]
                DataService.instance.createDBUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData)
                self.performSegue(withIdentifier: "tabbedVC", sender: self)
                //self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
