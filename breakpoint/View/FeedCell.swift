//
//  FeedCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 29/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    func configureCell(profileImage: UIImage, username: String, content: String) {
        self.profileImage.image = profileImage
        self.usernameLbl.text = username
        self.contentLbl.text = content
    }

}
