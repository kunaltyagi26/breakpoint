//
//  ChatFeedVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 14/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import FirebaseAuth
import RAMAnimatedTabBarController
import FirebaseStorage
import MobileCoreServices
import AVFoundation

class ChatFeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var sendMessageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var name: String?
    var image: String?
    var selectedId: String?
    var messages = [ChatMessage]()
    var keyboardSize: CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        messageTextView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 8, right: 0)
        progressView.alpha = 0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        tableView.bindToKeyboard { (completed) in
            if completed {
            
            }
        }
        sendMessageView.bindToKeyboard { (completed) in
            if completed {
                
            }
        }
        messageTextView.layer.cornerRadius = 15
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        keyboardShow { (completed) in
            if completed {
                if self.messages.count > 0 {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }
    
    func keyboardShow(completion: @escaping (_ status: Bool)-> ()) {
        tableViewTopConstraint.constant += 99
        //print(tableViewTopConstraint.constant)
        completion(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        tableViewTopConstraint.constant = 0
        //print(tableViewTopConstraint.constant)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.getAllChatMessages(userId: selectedId!) { (chatMessageArray) in
            self.messages = chatMessageArray
            self.tableView.reloadData()
            
            if self.messages.count > 0 {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
        self.profileImage.image = UIImage(named: image!)
        self.username.text = name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabbarController = segue.destination as! RAMAnimatedTabBarController
        tabbarController.setSelectIndex(from: 0, to: 1)
    }
    
    @IBAction func uploadImagePressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func sendPressed(_ sender: Any) {
        if messageTextView.text != "" {
            var message: ChatMessage
            messageTextView.isEditable = false
            sendBtn.isEnabled = false
            let fromId = Auth.auth().currentUser?.uid
            let toId = selectedId
            let content = messageTextView.text
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            let timeStamp = "\(dateFormatter.string(from: Date() as Date))"
            message = ChatMessage(content: content!, imageUrl: nil, imageWidth: nil, imageHeight: nil, videoUrl: nil, fromId: fromId!, toId: toId!, timestamp: timeStamp)
            DataService.instance.uploadChatMessage(chatMessage: message, completion: { (completed) in
                if completed {
                    self.messageTextView.text = ""
                    self.messageTextView.isEditable = true
                    self.sendBtn.isEnabled = true
                }
            })
        }
    }
    
    func initData(id: String, username: String, profileImage: String) {
        self.selectedId = id
        self.name = username
        self.image = profileImage
    }
    
}

extension ChatFeedVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(messages.count)
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatFeedCell") as? ChatFeedCell else { return UITableViewCell() }
        let chatMessage = messages[indexPath.row]
        cell.configureCell(chatMessage: chatMessage)
        return cell
    }
}

extension ChatFeedVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            uploadVideo(videoUrl: videoUrl)
        }
        else {
            var selectedImage = UIImage()
            
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImage = editedImage
            }
            else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                selectedImage = originalImage
            }
            uploadImage(selectedImage: selectedImage, completion: { (imageUrl) in
                
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadVideo(videoUrl: NSURL) {
        progressView.alpha = 1
        let filename = NSUUID().uuidString
        let uploadTask = Storage.storage().reference().child("message_videos").child(filename).putFile(from: videoUrl as URL, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("Failed to upload video", error)
                return
            }
            
            if let uploadedVideoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnail = self.thumbnailImageForVideoUrl(videoUrl: videoUrl) {
                    let imageName = NSUUID().uuidString
                    let ref = Storage.storage().reference().child("message_images").child(imageName)
                    if let image = UIImageJPEGRepresentation(thumbnail, 0.2) {
                        let uploadTask = ref.putData(image, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print("Failed to upload image.")
                                return
                            }
                            else {
                                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                                    var message: ChatMessage
                                    let fromId = Auth.auth().currentUser?.uid
                                    let toId = self.selectedId
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.timeStyle = .short
                                    let timeStamp = "\(dateFormatter.string(from: Date() as Date))"
                                    print("Uploaded video url: ", uploadedVideoUrl)
                                    message = ChatMessage(content: nil, imageUrl: imageUrl, imageWidth: thumbnail.size.width as NSNumber, imageHeight: thumbnail.size.height as NSNumber, videoUrl: uploadedVideoUrl, fromId: fromId!, toId: toId!, timestamp: timeStamp)
                                    DataService.instance.uploadChatMessage(chatMessage: message, completion: { (completed) in
                                        if completed {
                                            self.sendBtn.isEnabled = true
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            }
        })
        uploadTask.observe(.progress, handler: { (snapshot) in
            self.username.text = "Sending..."
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            self.progressView.progress = Float(percentComplete)
        })
        uploadTask.observe(.success, handler: { (snapshot) in
            self.username.text = self.name
            self.progressView.alpha = 0
        })
    }
    
    private func thumbnailImageForVideoUrl(videoUrl: NSURL) -> UIImage? {
        let asset = AVAsset(url: videoUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let err {
            print(err)
        }
        return nil
    }
    
    func uploadImage(selectedImage: UIImage, completion: @escaping (_ imageUrl: String)-> ()) {
        progressView.alpha = 1
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let image = UIImageJPEGRepresentation(selectedImage, 0.2) {
            let uploadTask = ref.putData(image, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image.")
                    return
                }
                else {
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        var message: ChatMessage
                        let fromId = Auth.auth().currentUser?.uid
                        let toId = self.selectedId
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .short
                        let timeStamp = "\(dateFormatter.string(from: Date() as Date))"
                        print("Width:", selectedImage.size.width as NSNumber)
                        print("Height:", selectedImage.size.height as NSNumber)
                        message = ChatMessage(content: nil, imageUrl: imageUrl, imageWidth: selectedImage.size.width as NSNumber, imageHeight: selectedImage.size.height as NSNumber, videoUrl: nil, fromId: fromId!, toId: toId!, timestamp: timeStamp)
                        DataService.instance.uploadChatMessage(chatMessage: message, completion: { (completed) in
                            if completed {
                                self.sendBtn.isEnabled = true
                                completion(imageUrl)
                            }
                        })
                    }
                }
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                self.username.text = "Sending..."
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                self.progressView.progress = Float(percentComplete)
            })
            uploadTask.observe(.success, handler: { (snapshot) in
                self.username.text = self.name
                self.progressView.alpha = 0
            })
        }
    }
}
