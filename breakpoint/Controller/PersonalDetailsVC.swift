//
//  PersonalDetailsVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 10/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import NVActivityIndicatorView

class PersonalDetailsVC: UIViewController {

    @IBOutlet weak var nameTxt: InsetTextField!
    @IBOutlet weak var selectProfileBtn: UIButton!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    //var email: String?
    //var password: String?
    var image: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Called")
        /*if image != nil {
            selectProfileBtn.setImage(image, for: .normal)
        }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DataService.instance.avatarName != ""
        {
            image = DataService.instance.avatarName
            selectProfileBtn.setImage(UIImage(named: image!), for: .normal)
            let avatarName = DataService.instance.avatarName
            if avatarName.contains("light")
            {
                selectProfileBtn.backgroundColor = UIColor.lightGray
            }
            else if avatarName.contains("dark") {
                selectProfileBtn.backgroundColor = UIColor.white
            }
        }
    }
    
    /*func getCredentials(email: String, password: String) {
        self.email = email
        self.password = password
    }*/

    /*func setImage(selectedImage: UIImage) {
        print(selectedImage)
        self.image = selectedImage
        print(image!)
        print("Image set to image var.")
        //selectProfileBtn.setImage(image, for: .normal)
    }
    
    func configureImage(selectedImage: UIImage) {
        print("Entered configure.")
        print(selectedImage)
        if let tempBtn = self.selectProfileBtn
        {
            tempBtn.setImage(selectedImage, for: .normal)
        }
        else {
            print("Button is nil.")
        }
        selectProfileBtn.setImage(selectedImage, for: .normal)
    }*/
    
    @IBAction func backPressed(_ sender: Any) {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        let loginManager: LoginManager = LoginManager()
        loginManager.logOut()
        Auth.auth().currentUser?.delete(completion: { (error) in
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            self.activityIndicatorView.stopAnimating()
            self.present(loginVC!, animated: true, completion: nil)
        })
    }
    
    @IBAction func NextPressed(_ sender: Any) {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            let userData = ["name": self.nameTxt.text!, "image": self.image!]
            DataService.instance.updateNameAndPicture(uid: (user?.uid)!, userData: userData)
            self.activityIndicatorView.stopAnimating()
            self.performSegue(withIdentifier: "tabbedVC", sender: self)
        }
    }
    
    @IBAction func imageBtnPressed(_ sender: Any) {
        guard let popOverVC = storyboard?.instantiateViewController(withIdentifier: "imageSelectionVC") as? ImageSelectionVC else { return }
        /*self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.showAnimate()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.present(popOverVC, animated: false, completion: nil)
        }, completion: nil)*/
        present(popOverVC, animated: false, completion: nil)
    }
}


