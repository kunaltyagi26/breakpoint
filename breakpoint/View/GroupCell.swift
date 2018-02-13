//
//  GroupCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 03/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var groupDescriptionLbl: UILabel!
    @IBOutlet weak var membersCountLbl: UILabel!
    
    func configureCell(groupTitle: String, groupDesc: String, membersCount: Int) {
        self.groupTitleLbl.text = groupTitle
        self.groupDescriptionLbl.text = groupDesc
        self.membersCountLbl.text = "\(membersCount) members"
    }
}
