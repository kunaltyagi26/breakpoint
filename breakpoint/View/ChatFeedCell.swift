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
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var zoomingImageView: UIImageView?
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close"), for: .normal)
        return button
    }()
    
    @objc func closePressed() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.closeButton.removeFromSuperview()
            self.zoomingImageView?.frame = self.startingFrame!
            self.blackBackgroundView?.alpha = 0
        }) { (completed) in
            if completed {
                self.zoomingImageView?.removeFromSuperview()
            }
        }
    }
    
    @objc func handleZoom(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
            zoomingImageView = UIImageView(frame: startingFrame!)
            zoomingImageView?.image = messageImageView.image
            if let keyWindow = UIApplication.shared.keyWindow {
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = UIColor.black
                blackBackgroundView?.alpha = 0
                keyWindow.addSubview(blackBackgroundView!)
                keyWindow.addSubview(zoomingImageView!)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    keyWindow.addSubview(self.closeButton)
                    self.closeButton.leftAnchor.constraint(equalTo: (self.superview?.leftAnchor)!, constant: 20).isActive = true
                    self.closeButton.topAnchor.constraint(equalTo: (self.blackBackgroundView?.topAnchor)!, constant: 50).isActive = true
                    self.blackBackgroundView?.alpha = 1
                    let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                    self.zoomingImageView?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    self.zoomingImageView?.center = keyWindow.center
                }, completion: nil)
            }
        }
    }
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject)  as? UIImage {
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
        }).resume()
        
        /*let storageRef = Storage.storage().reference(forURL: urlString)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            let pic = UIImage(data: data!)
            self.messageImageView.image = pic
        }*/
    }
    
    func configureCell(chatMessage: ChatMessage) {
        messageView.isUserInteractionEnabled = true
        messageImageView.isUserInteractionEnabled = true
        messageView.addSubview(messageImageView)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom)))
        if chatMessage.imageUrl != nil {
            messageImageView.alpha = 1
            message.alpha = 0
            if let imageUrl = chatMessage.imageUrl {
                loadImageUsingCacheWithUrlString(urlString: imageUrl)
            }
            messageImageView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: 6).isActive = true
            messageImageView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 6).isActive = true
            messageImageView.rightAnchor.constraint(equalTo: timeStamp.rightAnchor, constant: -6).isActive = true
            messageImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            messageImageView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -6).isActive = true
            contentView.bringSubview(toFront: messageImageView)
            messageView.bringSubview(toFront: timeStamp)
        }
        else {
            messageImageView.removeFromSuperview()
            message.alpha = 1
            self.message.text = chatMessage.content
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
