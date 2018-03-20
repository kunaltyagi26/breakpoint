//
//  NewChatVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 13/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class NewChatVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [Users]()
    var idArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.getAllContacts { (idArray, userArray) in
            self.idArray = idArray
            //print(self.idArray)
            self.users = userArray
            self.tableView.reloadData()
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        guard let chatVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as? ChatVC else { return }
        present(chatVC, animated: true, completion: nil)
    }
}

extension NewChatVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newChatCell") as? NewChatCell else { return UITableViewCell() }
        let user = users[indexPath.row]
        cell.configureCell(profileImage: UIImage(named: user.profileImage)!, name: user.name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatFeedVC = storyboard?.instantiateViewController(withIdentifier: "chatFeedVC") as? ChatFeedVC else { return }
        //print(indexPath.row)
        //print(idArray[indexPath.row])
        //print(users[indexPath.row].name)
        chatFeedVC.initData(id: idArray[indexPath.row], username: users[indexPath.row].name, profileImage: users[indexPath.row].profileImage)
        present(chatFeedVC, animated: true, completion: nil)
    }
}
