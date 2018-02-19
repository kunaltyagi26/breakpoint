//
//  FirstViewController.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 23/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import SkeletonView
import RAMAnimatedTabBarController

class FeedsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        //tableView.isSkeletonable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //view.showGradientSkeleton()
        //view.startSkeletonAnimation()
        DataService.instance.getAllFeedMessages { (messageArray) in
            self.messages = messageArray.reversed()
            self.tableView.reloadData()
        }
    }
    @IBAction func addPressed(_ sender: Any) {
        guard let createPostVC = storyboard?.instantiateViewController(withIdentifier: "createPostVC") as? CreatePostVC else { return }
        presentDetail(viewControllerToPresent: createPostVC)
    }
}

extension FeedsVC: UITableViewDelegate, UITableViewDataSource, SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdenfierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FeedCell"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell else { return UITableViewCell() }
        let message = messages[indexPath.row]
        DataService.instance.getUserNameAndImage(ForUID: message.senderId) { (userName, image) in
            cell.configureCell(profileImage: UIImage(named: image)!, username: userName, content: message.content)
        }
        //tableView.isSkeletonable = false
        //tableView.stopSkeletonAnimation()
        //tableView.hideSkeleton()
        return cell
    }
}
