//
//  GroupFeedCell.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 03/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import AVFoundation

class GroupFeedCell: UITableViewCell {
    //@IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var timestamp: UILabel!
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var zoomingImageView: UIImageView?
    var startingImageView: UIImageView?
    var url: String?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
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
    
    let playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "play"), for: .normal)
        return button
    }()
    
    @objc func closePressed() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.closeButton.removeFromSuperview()
            self.zoomingImageView?.frame = self.startingFrame!
            self.blackBackgroundView?.alpha = 0
            self.messageView.backgroundColor = UIColor.clear
        }) { (completed) in
            if completed {
                self.zoomingImageView?.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    @objc func playPressed() {
        playButton.alpha = 0
        //self.startingImageView?.removeFromSuperview()
        player = AVPlayer(url: NSURL(string: url!)! as URL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = messageView.bounds
        messageView.layer.addSublayer(playerLayer!)
        player?.play()
        activityIndicatorView.alpha = 1
        activityIndicatorView.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    @objc func handleZoom(tapGesture: UITapGestureRecognizer) {
        if url != nil {
            return
        }
        if let imageView = tapGesture.view as? UIImageView {
            messageView.backgroundColor = UIColor.clear
            self.startingImageView = imageView
            self.startingImageView?.isHidden = true
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
    
    func configureCell(username: String, chatMessage: ChatMessage) {
        url = chatMessage.videoUrl
        messageView.isUserInteractionEnabled = true
        messageImageView.isUserInteractionEnabled = true
        playButton.isUserInteractionEnabled = true
        messageView.addSubview(messageImageView)
        messageView.addSubview(playButton)
        messageImageView.addSubview(activityIndicatorView)
        activityIndicatorView.alpha = 0
        playButton.addTarget(self, action: #selector(playPressed), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom)))
        
        if chatMessage.imageUrl != nil {
            if chatMessage.videoUrl != nil {
                playButton.alpha = 1
                //messageImageView.isUserInteractionEnabled = false
            }
            else {
                playButton.alpha = 0
                //messageImageView.isUserInteractionEnabled = true
            }
            messageImageView.alpha = 1
            contentLbl.alpha = 0
            if let imageUrl = chatMessage.imageUrl {
                loadImageUsingCacheWithUrlString(urlString: imageUrl)
            }
            
            playButton.centerXAnchor.constraint(equalTo: messageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: messageView.centerYAnchor).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: messageView.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: messageView.centerYAnchor).isActive = true
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            messageImageView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: 0).isActive = true
            messageImageView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 0).isActive = true
            messageImageView.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: 0).isActive = true
            if chatMessage.content != nil {
                //print("Entered in content section.")
                //messageImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            }
            else {
                //print("Entered in image section.")
                if let height = chatMessage.imageHeight as? CGFloat, let width = chatMessage.imageWidth as? CGFloat {
                    let finalHeight = CGFloat(height / width * 250)
                    //print("height: ", finalHeight)
                    messageImageView.heightAnchor.constraint(equalToConstant: finalHeight).isActive = true
                }
            }
            messageImageView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 0).isActive = true
            
            contentView.bringSubview(toFront: messageImageView)
            messageView.bringSubview(toFront: timestamp)
            messageView.bringSubview(toFront: usernameLbl)
        }
        else {
            messageImageView.removeFromSuperview()
            playButton.removeFromSuperview()
            contentLbl.alpha = 1
            self.contentLbl.text = chatMessage.content
        }
        
        messageView.layer.cornerRadius = 15
        if chatMessage.fromId == Auth.auth().currentUser?.uid {
            let constraint = NSLayoutConstraint(item: messageView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal
                , toItem: self.contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -16)
            NSLayoutConstraint.activate([constraint])
            contentLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            timestamp.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            messageView.backgroundColor = #colorLiteral(red: 0.2978684604, green: 0.3234421611, blue: 1, alpha: 1)
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        }
        else {
            let constraint = NSLayoutConstraint(item: messageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal
                , toItem: self.contentView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 16)
            NSLayoutConstraint.activate([constraint])
            contentLbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            timestamp.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            messageView.backgroundColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 0.3039383562)
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
        
        messageView.clipsToBounds = true
        self.timestamp.text = chatMessage.timestamp
        
        self.usernameLbl.text = username
        self.contentLbl.text = chatMessage.content
    }
}
