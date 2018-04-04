//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 03/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase

class GroupFeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMessageView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var group: Group?
    var emailArray: [String]?
    var groupMessages = [Message]()
    
    func initGroupData(forGroup group: Group) {
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 8, right: 0)
        tableView.tableViewBindToKeyboard()
        sendMessageView.bindToKeyboard { (completed) in
            
        }
        tableView.delegate = self
        tableView.dataSource = self
        messageTextView.layer.cornerRadius = 15
        screenTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        groupTitle.text = group?.groupTitle
        DataService.instance.getEmailsFor(group: group!) { (returnedEmails ) in
            self.emailArray = returnedEmails
        }
        DataService.instance.REF_GROUPS.observe(.value) { (groupSnspshot) in
            DataService.instance.GetAllMessagesFor(desiredGroup: self.group!, completion: { (returnedGroupMessages) in
                self.groupMessages = returnedGroupMessages
                self.tableView.reloadData()
                
                if self.groupMessages.count > 0 {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.groupMessages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
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
    
    @IBAction func sendPressed(_ sender: Any) {
        if messageTextView.text != "" {
            messageTextView.isEditable = false
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: messageTextView.text, forUID: (Auth.auth().currentUser?.uid)!, withGroupKey: group?.groupId, completion: { (complete) in
                if complete {
                    self.messageTextView.text = ""
                    self.messageTextView.isEditable = true
                    self.sendBtn.isEnabled = true
                }
            })
        }
    }
    @IBAction func backPressed(_ sender: Any) {
        dismissDetail()
    }
}

extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell") as? GroupFeedCell else { return UITableViewCell() }
        let message = groupMessages[indexPath.row]
        //let image = UIImage(named: "defaultProfileImage")
        DataService.instance.getUserNameAndImage(ForUID: message.senderId) { (username, image, imageBackground) in
            cell.configureCell(image: UIImage(named: image)!, imageBackground: imageBackground, username: username, content: message.content)
        }
        return cell
    }
}
