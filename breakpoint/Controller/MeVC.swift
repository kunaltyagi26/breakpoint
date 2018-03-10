//
//  MeVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 28/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import NVActivityIndicatorView

class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    var overlay: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlay = UIView(frame: view.frame)
        overlay!.backgroundColor = UIColor.black
        overlay!.alpha = 0.8
        view.addSubview(overlay!)
        self.view.bringSubview(toFront: self.activityIndicatorView)
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadData { (completed) in
                if completed {
                    //self.overlay!.alpha = 0.8
//                    self.overlay!.removeFromSuperview()
//                    self.activityIndicatorView.stopAnimating()
//                    self.activityIndicatorView.isHidden = true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadData(completion: @escaping (_ status: Bool)-> ()) {
        DataService.instance.getUserNameAndImage(ForUID: (Auth.auth().currentUser?.uid)!) { (username, image, imageBackground) in
//            self.overlay = UIView(frame: self.view.frame)
//            self.overlay!.backgroundColor = UIColor.black
//            self.overlay!.alpha = 0.8
//            self.view.addSubview(self.overlay!)
//            self.view.bringSubview(toFront: self.activityIndicatorView)
            self.overlay!.removeFromSuperview()
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.profileImage.layer.cornerRadius = 40
            self.usernameLbl.text = username
            self.profileImage.image = UIImage(named: image)
            if imageBackground == "black" {
                self.profileImage.backgroundColor = UIColor.black
            }
            else {
                self.profileImage.backgroundColor = UIColor.white
            }
        }
        completion(true)
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (buttonTapped) in
            do {
                try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(cancelAction)
        let loginManager: LoginManager = LoginManager()
        loginManager.logOut()
        present(logoutPopup, animated: true, completion: nil)
    }
    
}
