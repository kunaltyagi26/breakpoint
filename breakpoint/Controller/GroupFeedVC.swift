//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 03/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit
import Firebase
import RAMAnimatedTabBarController
import FirebaseStorage
import MobileCoreServices
import AVFoundation

class GroupFeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMessageView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var group: Group?
    var emailArray: [String]?
    var groupMessages = [ChatMessage]()
    var name: String?
    
    func initGroupData(forGroup group: Group) {
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 8, right: 0)
        progressView.alpha = 0
        tableView.tableViewBindToKeyboard()
        sendMessageView.bindToKeyboard { (completed) in
            
        }
        tableView.delegate = self
        tableView.dataSource = self
        messageTextView.layer.cornerRadius = 15
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        //screenTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.name = group?.groupTitle
        groupTitle.text = name
        DataService.instance.getEmailsFor(group: group!) { (returnedEmails ) in
            self.emailArray = returnedEmails
        }
        
        DataService.instance.GetAllMessagesFor(desiredGroup: self.group!, completion: { (returnedGroupMessages) in
            self.groupMessages = returnedGroupMessages
            self.tableView.reloadData()
            /*self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
            self.tableView.reloadData()
            
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            self.tableView.reloadData()*/
            
            if self.groupMessages.count > 0 {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.groupMessages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabbarController = segue.destination as! RAMAnimatedTabBarController
        tabbarController.setSelectIndex(from: 0, to: 2)
    }
    
    @IBAction func uploadMediaPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func screenTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        view.addGestureRecognizer(tap)
    }
    
    @objc func screenTapAction(){
        view.endEditing(true)
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        if messageTextView.text != "" || messageTextView.text != " " {
            messageTextView.isEditable = false
            sendBtn.isEnabled = false
            
            var message: ChatMessage
            let fromId = Auth.auth().currentUser?.uid
            let content = messageTextView.text
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            let timeStamp = "\(dateFormatter.string(from: Date() as Date))"
            message = ChatMessage(content: content!, imageUrl: nil, imageWidth: nil, imageHeight: nil, videoUrl: nil, fromId: fromId!, toId: nil, timestamp: timeStamp)
            
            DataService.instance.uploadChatMessage(chatMessage: message, groupKey: group?.groupId, completion: { (complete) in
                if complete {
                    self.messageTextView.text = ""
                    self.messageTextView.isEditable = true
                    self.sendBtn.isEnabled = true
                }
            })
            /*DataService.instance.uploadPost(withMessage: messageTextView.text, forUID: (Auth.auth().currentUser?.uid)!, withGroupKey: group?.groupId, completion: { (complete) in
                if complete {
                    self.messageTextView.text = ""
                    self.messageTextView.isEditable = true
                    self.sendBtn.isEnabled = true
                }
            })*/
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismissDetail()
    }
}

extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell") as? GroupFeedCell else { return UITableViewCell() }
        let message = groupMessages[indexPath.row]
        //let image = UIImage(named: "defaultProfileImage")
        //print("Message:", message.content!)
        //print("Timestamp:", message.timestamp)
        DataService.instance.getUserNameAndImage(ForUID: message.fromId) { (username, image, imageBackground) in
            cell.configureCell(username: username, chatMessage: message)
        }
        //cell.contentLbl.preferredMaxLayoutWidth = cell.contentLbl.bounds
        cell.layoutIfNeeded()
        return cell
    }
}

extension GroupFeedVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.timeStyle = .short
                                    let timeStamp = "\(dateFormatter.string(from: Date() as Date))"
                                    print("Uploaded video url: ", uploadedVideoUrl)
                                    message = ChatMessage(content: nil, imageUrl: imageUrl, imageWidth: thumbnail.size.width as NSNumber, imageHeight: thumbnail.size.height as NSNumber, videoUrl: uploadedVideoUrl, fromId: fromId!, toId: nil, timestamp: timeStamp)
                                    DataService.instance.uploadChatMessage(chatMessage: message, groupKey: self.group?.groupId,  completion: { (completed) in
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
            self.groupTitle.text = "Sending..."
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            self.progressView.progress = Float(percentComplete)
        })
        uploadTask.observe(.success, handler: { (snapshot) in
            self.groupTitle.text = self.name
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
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .short
                        let timeStamp = "\(dateFormatter.string(from: Date() as Date))"
                        print("Width:", selectedImage.size.width as NSNumber)
                        print("Height:", selectedImage.size.height as NSNumber)
                        message = ChatMessage(content: nil, imageUrl: imageUrl, imageWidth: selectedImage.size.width as NSNumber, imageHeight: selectedImage.size.height as NSNumber, videoUrl: nil, fromId: fromId!, toId: nil, timestamp: timeStamp)
                        DataService.instance.uploadChatMessage(chatMessage: message, groupKey: self.group?.groupId, completion: { (completed) in
                            if completed {
                                self.sendBtn.isEnabled = true
                                completion(imageUrl)
                            }
                        })
                    }
                }
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                self.groupTitle.text = "Sending..."
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                self.progressView.progress = Float(percentComplete)
            })
            uploadTask.observe(.success, handler: { (snapshot) in
                self.groupTitle.text = self.name
                self.progressView.alpha = 0
            })
        }
    }
}
