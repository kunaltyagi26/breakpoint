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

class ChatFeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var sendMessageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
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
        tableViewTopConstraint.constant += (keyboardSize?.height)! - 35
        completion(true)
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
            message = ChatMessage(content: content!, imageUrl: nil, fromId: fromId!, toId: toId!, timestamp: timeStamp)
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
        var selectedImage = UIImage()
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        uploadImage(selectedImage: selectedImage)
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(selectedImage: UIImage) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let image = UIImageJPEGRepresentation(selectedImage, 0.2) {
            ref.putData(image, metadata: nil, completion: { (metadata, error) in
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
                        message = ChatMessage(content: nil, imageUrl: imageUrl, fromId: fromId!, toId: toId!, timestamp: timeStamp)
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
