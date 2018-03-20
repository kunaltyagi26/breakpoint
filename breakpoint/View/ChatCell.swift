//
//  ChatCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 13/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var recentMessage: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    func configureCell(profileImage: UIImage, name: String, recentMessage: String, timestamp: String) {
        self.profileImage.layer.cornerRadius = 20
        self.profileImage.image = profileImage
        self.name.text = name
        self.recentMessage.text = recentMessage
        self.timestamp.text = timestamp
    }
    
}
