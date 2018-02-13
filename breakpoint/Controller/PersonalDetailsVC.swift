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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
            self.present(authVC!, animated: true, completion: nil)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    @IBAction func NextPressed(_ sender: Any) {
        
    }
}
