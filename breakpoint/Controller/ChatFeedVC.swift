//
//  ChatFeedVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 14/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import FirebaseAuth
import RAMAnimatedTabBarController

class ChatFeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var sendMessageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var name: String?
    var image: String?
    var selectedId: String?
    var messages = [ChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        messageTextView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 8, right: 0)
        tableView.tableViewBindToKeyboard()
        messageTextView.autocorrectionType = .no
        sendMessageView.bindToKeyboard()
        messageTextView.layer.cornerRadius = 15
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print(selectedId!)
        DataService.instance.getAllChatMessages(userId: selectedId!) { (chatMessageArray) in
            //print(chatMessageArray)
            self.messages = chatMessageArray
            //print(self.messages)
            self.tableView.reloadData()
            
            if self.messages.count > 0 {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
        self.profileImage.image = UIImage(named: image!)
        self.username.text = name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabbarController = segue.destination as! RAMAnimatedTabBarController
        tabbarController.setSelectIndex(from: 0, to: 1)
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        if messageTextView.text != "" {
            var message: ChatMessage
            messageTextView.isEditable = false
            sendBtn.isEnabled = false
            let fromId = Auth.auth().currentUser?.uid
            let toId = selectedId
            let content = messageTextView.text
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            let timeStamp = "\(dateFormatter.string(from: Date() as Date))"
            message = ChatMessage(content: content!, fromId: fromId!, toId: toId!, timestamp: timeStamp)
            DataService.instance.uploadChatMessage(chatMessage: message, completion: { (completed) in
                if completed {
                    self.messageTextView.text = ""
                    self.messageTextView.isEditable = true
                    self.sendBtn.isEnabled = true
                }
            })
        }
    }
    
    func initData(id: String, username: String, profileImage: String) {
        self.selectedId = id
        self.name = username
        self.image = profileImage
    }
    
}

extension ChatFeedVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(messages.count)
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatFeedCell") as? ChatFeedCell else { return UITableViewCell() }
        let chatMessage = messages[indexPath.row]
        cell.configureCell(chatMessage: chatMessage)
        return cell
    }

}
