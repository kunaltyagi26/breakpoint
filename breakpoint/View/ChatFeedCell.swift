//
//  ChatFeedCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 14/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase

class ChatFeedCell: UITableViewCell {
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    func configureCell(chatMessage: ChatMessage) {
        messageView.layer.cornerRadius = 15
        if chatMessage.fromId == Auth.auth().currentUser?.uid {
            message.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            timeStamp.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        }
        else {
            message.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            timeStamp.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
        
        messageView.clipsToBounds = true
        self.message.text = chatMessage.content
        self.timeStamp.text = chatMessage.timestamp
    }
}
