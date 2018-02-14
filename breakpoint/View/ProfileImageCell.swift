//
//  ProfileImageCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 15/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class ProfileImageCell: UICollectionViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    
    func configureCell(image: UIImage) {
        self.profileImage.image = image
    }
}
