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
    @IBOutlet weak var selectProfileBtn: UIButton!
    
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
        Auth.auth().currentUser?.delete(completion: { (error) in
            let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
            self.present(authVC!, animated: true, completion: nil)
        })
    }
    
    @IBAction func NextPressed(_ sender: Any) {
        AuthService.instance.loginUser(withEmail: self.email!, andPassword: password!, completion: { (success, nil) in
            if success {
                let userData = ["provider": Auth.auth().currentUser?.providerID, "email": Auth.auth().currentUser?.email, "name": self.nameTxt.text!]
                DataService.instance.createDBUser(uid: (Auth.auth().currentUser?.uid)!, userData: userData)
                self.performSegue(withIdentifier: "tabbedVC", sender: self)
            }
        })
    }
    
    @IBAction func imageBtnPressed(_ sender: Any) {
        guard let popOverVC = storyboard?.instantiateViewController(withIdentifier: "imageSelectionVC") as? ImageSelectionVC else { return }
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
}


