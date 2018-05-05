//
//  SecondViewController.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 23/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class GroupsVC: UIViewController {

    @IBOutlet weak var groupsTableView: UITableView!
    
    var groupArray = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        groupsTableView.rowHeight = UITableViewAutomaticDimension
        groupsTableView.estimatedRowHeight = 50.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
            DataService.instance.getAllGroups { (returnedGroupArray) in
                self.groupArray = returnedGroupArray
                self.groupsTableView.reloadData()
            }
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        guard let createGroupVC = storyboard?.instantiateViewController(withIdentifier: "createGroupsVC") as? CreateGroupsVC else { return }
        presentDetail(viewControllerToPresent: createGroupVC)
    }
    
}

extension GroupsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as? GroupCell else { return UITableViewCell() }
        let group = groupArray[indexPath.row]
        cell.configureCell(groupTitle: group.groupTitle, groupDesc: group.groupDesciption, membersCount: group.membersCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let groupFeedVC = storyboard?.instantiateViewController(withIdentifier: "groupFeedVC") as? GroupFeedVC else { return }
        groupFeedVC.initGroupData(forGroup: groupArray[indexPath.row])
        presentDetail(viewControllerToPresent: groupFeedVC)
    }
}

