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
        DataService.instance.getChatContactDetails(id: (Auth.auth().currentUser?.uid)!) { (users) in
            self.userArray = users
//            for user in self.userArray {
//                print(user.name)
//                print(user.profileImage)
//            }
            print(self.userArray.count)
            //self.chatMessageArray = chatMessages
            self.tableView.reloadData()
        }
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
        print(userArray.count)
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as? ChatCell else { return UITableViewCell() }
        print(userArray[indexPath.row].name)
        cell.configureCell(profileImage: UIImage(named: userArray[indexPath.row].profileImage)!, name: userArray[indexPath.row].name, recentMessage: chatMessageArray[indexPath.row].content, timestamp: chatMessageArray[indexPath.row].timestamp)
        return cell
    }
}
