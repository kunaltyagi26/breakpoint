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
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    func configureCell(image: UIImage, email: String, content: String) {
        self.profileImage.image = image
        self.emailLbl.text = email
        self.contentLbl.text = content
    }
}
