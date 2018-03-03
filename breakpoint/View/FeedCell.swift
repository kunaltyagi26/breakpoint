//
//  FeedCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 29/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import SkeletonView

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    func configureCell(profileImage: UIImage, imageBackground: String, username: String, content: String) {
        self.profileImage.layer.cornerRadius = 20
        self.profileImage.image = profileImage
        if imageBackground == "black" {
            self.profileImage.backgroundColor = UIColor.black
        }
        else {
            self.profileImage.backgroundColor = UIColor.white
        }
        self.usernameLbl.text = username
        self.contentLbl.text = content
    }

}
