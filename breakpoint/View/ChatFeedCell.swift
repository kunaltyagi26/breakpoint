//
//  ChatFeedCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 14/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ChatFeedCell: UITableViewCell {
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    /*let messageContent: UILabel = {
        let message = UILabel()
        message.translatesAutoresizingMaskIntoConstraints = false
        message.layer.masksToBounds = true
        message.frame.size.height = 70
        return message
    }()*/
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        //imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        //imageView.backgroundColor = UIColor.black
        //imageView.image = UIImage(named: "light16")
        return imageView
    }()
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        /*if let cachedImage = imageCache.object(forKey: urlString as AnyObject)  as? UIImage {
            self.messageImageView.image = cachedImage
            return
        }
    
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    self.imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.messageImageView.image = downloadedImage
                }
            }
        }).resume()*/
        
        let storageRef = Storage.storage().reference(forURL: urlString)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            let pic = UIImage(data: data!)
            self.messageImageView.image = pic
        }
    }
    
    func configureCell(chatMessage: ChatMessage) {
        //self.addSubview(messageContent)
        messageView.addSubview(messageImageView)
        if chatMessage.imageUrl != nil {
            messageImageView.alpha = 1
            message.alpha = 0
            if let imageUrl = chatMessage.imageUrl {
                loadImageUsingCacheWithUrlString(urlString: imageUrl)
            }
            //self.messageImageView.image =
            //messageView.frame.size.height = 150
            messageImageView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: 6).isActive = true
            messageImageView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 6).isActive = true
            messageImageView.rightAnchor.constraint(equalTo: timeStamp.rightAnchor, constant: -6).isActive = true
            messageImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            messageImageView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -6).isActive = true
            messageView.bringSubview(toFront: timeStamp)
        }
        else {
            messageImageView.alpha = 0
            message.alpha = 1
            self.message.text = chatMessage.content
            /*messageContent.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: 16).isActive = true
            messageContent.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 16).isActive = true
            messageContent.rightAnchor.constraint(equalTo: timeStamp.leftAnchor, constant: -16).isActive = true
            messageContent.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 16).isActive = true*/
        }
        messageView.layer.cornerRadius = 15
        if chatMessage.fromId == Auth.auth().currentUser?.uid {
            let constraint = NSLayoutConstraint(item: messageView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal
                , toItem: self.contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -16)
            NSLayoutConstraint.activate([constraint])
            message.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            timeStamp.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            messageView.backgroundColor = #colorLiteral(red: 0.2978684604, green: 0.3234421611, blue: 1, alpha: 1)
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        }
        else {
            let constraint = NSLayoutConstraint(item: messageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal
                , toItem: self.contentView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -16)
            NSLayoutConstraint.activate([constraint])
            message.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            timeStamp.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            messageView.backgroundColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 0.3039383562)
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
        
        messageView.clipsToBounds = true
        self.timeStamp.text = chatMessage.timestamp
    }
}
