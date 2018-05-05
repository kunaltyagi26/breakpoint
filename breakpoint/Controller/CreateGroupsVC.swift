 //
//  CreateGroupsVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 30/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
 import Firebase

class CreateGroupsVC: UIViewController {

    @IBOutlet weak var TitleTxt: InsetTextField!
    @IBOutlet weak var DescriptionTxt: InsetTextField!
    @IBOutlet weak var emailSearchTxt: InsetTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    
    var emailArray = [String]()
    var chosenUserArray = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneBtn.isHidden = true
        TitleTxt.delegate = self
        DescriptionTxt.delegate = self
        emailSearchTxt.delegate = self
        TitleTxt.layer.cornerRadius = 10
        TitleTxt.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        TitleTxt.layer.borderWidth = 1.0
        DescriptionTxt.layer.cornerRadius = 10
        DescriptionTxt.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        DescriptionTxt.layer.borderWidth = 1.0
        emailSearchTxt.layer.cornerRadius = 10
        emailSearchTxt.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        emailSearchTxt.layer.borderWidth = 1.0
        TitleTxt.attributedPlaceholder = NSAttributedString(string: "Enter the title",
                                                            attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)])
        DescriptionTxt.attributedPlaceholder = NSAttributedString(string: "Enter the description",
                                                            attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)])
        emailSearchTxt.attributedPlaceholder = NSAttributedString(string: "Enter the email",
                                                            attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        emailSearchTxt.delegate = self
        emailSearchTxt.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        //screenTap()
    }
    
    @objc func textFieldDidChange() {
        if emailSearchTxt.text == "" {
            emailArray = []
        }
        else {
            DataService.instance.getEmail(forSearchQuery: emailSearchTxt.text!, completion: { (returnedEmailArray) in
                self.emailArray = returnedEmailArray
            })
        }
        tableView.reloadData()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        dismissDetail()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if TitleTxt.text != "" && DescriptionTxt.text != "" {
            DataService.instance.getIds(forUsernames: chosenUserArray, completion: { (idsArray) in
                var userIds = idsArray
                userIds.append((Auth.auth().currentUser?.uid)!)
                DataService.instance.createGroup(withTitle: self.TitleTxt.text!, andDescription: self.DescriptionTxt.text!, forUserIds: userIds, completion: { (groupCreated) in
                    if groupCreated {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        print("Group could not be created. Please try again.")
                    }
                })
            })
        }
    }
    
    func screenTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        view.addGestureRecognizer(tap)
    }
    
    @objc func screenTapAction(){
        view.endEditing(true)
    }
 }
 
 extension CreateGroupsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell else { return UITableViewCell() }
        let profileImage = UIImage(named: "defaultProfileImage")
        print(indexPath.row)
        if chosenUserArray.contains(emailArray[indexPath.row]) {
            cell.configureCell(profileImage: profileImage!, email: emailArray[indexPath.row], isSelected: true)
        }
        else {
            cell.configureCell(profileImage: profileImage!, email: emailArray[indexPath.row], isSelected: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else { return }
        if !chosenUserArray.contains(cell.emailLbl.text!) {
            chosenUserArray.append(cell.emailLbl.text!)
            doneBtn.isHidden = false
            print(chosenUserArray)
        }
        else {
            chosenUserArray = chosenUserArray.filter({ $0 != cell.emailLbl.text! })
            print(chosenUserArray)
            if chosenUserArray.count < 1 {
                doneBtn.isHidden = true
            }
        }
    }
 }
 
 extension CreateGroupsVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        textField.layer.borderWidth = 2.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        textField.layer.borderWidth = 1.0
    }
 }
 
