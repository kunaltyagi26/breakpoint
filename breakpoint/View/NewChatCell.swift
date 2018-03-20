//
//  NewChatCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 13/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class NewChatCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    func configureCell(profileImage: UIImage, name: String) {
        self.profileImage.layer.cornerRadius = 20
        self.profileImage.image = profileImage
        self.username.text = name
    }
}
