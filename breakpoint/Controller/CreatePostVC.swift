//
//  CreatePostVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 28/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase

class CreatePostVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTextView.delegate = self
        sendBtn.bindToKeyboard()
        screenTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.getUserNameAndImage(ForUID: (Auth.auth().currentUser?.uid)!) { (username, image) in
            self.usernameLbl.text = username
            self.profileImage.image = UIImage(named: image)
        }
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        if postTextView.text != nil && postTextView.text != "Say something here..." {
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: postTextView.text, forUID: (Auth.auth().currentUser?.uid)!, withGroupKey: nil, completion: { (complete) in
                if complete {
                    self.sendBtn.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    self.sendBtn.isEnabled = false
                    print("There is an error.")
                }
            })
        }
        else {
            sendBtn.isEnabled = false
        }
    }
    @IBAction func closePressed(_ sender: Any) {
        dismissDetail()
    }
    
    func screenTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        view.addGestureRecognizer(tap)
    }
    
    @objc func screenTapAction(){
        view.endEditing(true)
    }
}

extension CreatePostVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = "Say something here..."
    }
}
