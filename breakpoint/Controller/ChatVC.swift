//
//  ChatVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 13/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase

class ChatVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var userArray = [Users]()
    var chatMessageArray = [ChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DataService.instance.getChatContactMessages(id: (Auth.auth().currentUser?.uid)!, completion: { (chatMessages) in
            self.chatMessageArray = chatMessages
            DataService.instance.getChatContactDetails(id: (Auth.auth().currentUser?.uid)!) { (users) in
                self.userArray = users
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func newChatPressed(_ sender: Any) {
        guard let newChatVC = storyboard?.instantiateViewController(withIdentifier: "newChatVC") as? NewChatVC else { return }
        present(newChatVC, animated: true, completion: nil)
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as? ChatCell else { return UITableViewCell() }
        cell.configureCell(profileImage: UIImage(named: userArray[indexPath.row].profileImage)!, name: userArray[indexPath.row].name, recentMessage: chatMessageArray[indexPath.row].content, timestamp: chatMessageArray[indexPath.row].timestamp)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatFeedVC = storyboard?.instantiateViewController(withIdentifier: "chatFeedVC") as? ChatFeedVC else { return }
        DataService.instance.getUserId(username: userArray[indexPath.row].name) { (userId) in
            chatFeedVC.initData(id: userId, username: self.userArray[indexPath.row].name, profileImage: self.userArray[indexPath.row].profileImage)
            self.present(chatFeedVC, animated: true, completion: nil)
        }
    }
}
