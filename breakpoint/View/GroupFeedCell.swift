//
//  GroupFeedCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 03/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class GroupFeedCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    func configureCell(image: UIImage, imageBackground: String, username: String, content: String) {
        self.profileImage.layer.cornerRadius = 20
        self.profileImage.image = image
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
