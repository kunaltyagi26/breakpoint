//
//  FeedsVC.swift
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
        let gradient = SkeletonGradient(baseColor: UIColor.turquoise)
        //let animation = GradientDirection.topLeftBottomRight.slidingAnimation()
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .bottomRightTopLeft)
        //view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        //view.startSkeletonAnimation()
        DataService.instance.getAllFeedMessages { (messageArray) in
            //self.tableView.isSkeletonable = false
            //self.tableView.hideSkeleton()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell else { return UITableViewCell() }
        let message = messages[indexPath.row]
        DataService.instance.getUserNameAndImage(ForUID: message.senderId) { (userName, image, imageBackground) in
            cell.configureCell(profileImage: UIImage(named: image)!, imageBackground: imageBackground, username: userName, content: message.content)
        }
        return cell
    }
}
