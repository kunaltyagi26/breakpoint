//
//  UserCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 31/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    var showing = false
    
    func configureCell(profileImage: UIImage, email: String, isSelected: Bool) {
        self.profileImage.layer.cornerRadius = 15
        self.profileImage.image = profileImage
        self.emailLbl.text = email
        if isSelected {
            checkImage.isHidden = false
        }
        else {
            checkImage.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            if showing == false {
                checkImage.isHidden = false
                showing = true
            }
            else {
                checkImage.isHidden = true
                showing = false
            }
        }
    }

}
