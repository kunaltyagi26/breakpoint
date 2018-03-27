//
//  DataService.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 23/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    private var _REF_MESSAGES = DB_BASE.child("messages")
    private var _REF_CHATS = DB_BASE.child("chats")
    
    public private(set) var avatarName = UIImage()
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    var REF_FEED: DatabaseReference {
        return _REF_FEED
    }
    
    var REF_MESSAGES: DatabaseReference {
        return _REF_MESSAGES
    }
    
    var REF_CHATS: DatabaseReference {
        return _REF_CHATS
    }
    
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func deleteDBUser(uid: String, completion: @escaping (_ status: Bool)-> ()) {
        let ref = REF_USERS.child(uid)
        ref.removeValue()
        completion(true)
    }
    
    func checkForNewUser(uid: String, completion: @escaping (_ status: Bool)-> ()) {
        var users = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                users.append(user.key)
            }
            if !users.contains(uid) {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func updateNameAndPicture(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func uploadPost(withMessage message: String, forUID uid: String, withGroupKey groupKey: String?, completion: @escaping (_ status: Bool)-> ()) {
        if groupKey != nil {
            REF_GROUPS.child(groupKey!).child("messages").childByAutoId().updateChildValues(["content": message, "senderId": uid])
            completion(true)
        }
        else {
            REF_FEED.childByAutoId().updateChildValues(["content": message, "senderId": uid])
            completion(true)
        }
    }
    
    func uploadChatMessage(chatMessage: ChatMessage, completion: @escaping (_ status: Bool)-> ()) {
        let message = REF_MESSAGES.childByAutoId()
        let messageId = message.key
        message.updateChildValues(["fromId": chatMessage.fromId, "toId": chatMessage.toId, "content": chatMessage.content, "timestamp": chatMessage.timestamp])
        REF_CHATS.child(chatMessage.fromId).child(chatMessage.toId).updateChildValues([messageId: 1])
        completion(true)
    }
    
    func getAllFeedMessages(completion: @escaping (_ messages: [Message])-> ()) {
        var messageArray = [Message]()
        REF_FEED.observeSingleEvent(of: .value) { (feedMessageSnapshot) in
            guard let feedMessageSnapshot = feedMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for message in feedMessageSnapshot {
                let content = message.childSnapshot(forPath: "content").value as! String
                let senderId = message.childSnapshot(forPath: "senderId").value as! String
                let messageData = Message(content: content, senderId: senderId)
                messageArray.append(messageData)
            }
            completion(messageArray)
        }
    }
    
    func GetAllMessagesFor(desiredGroup group: Group, completion: @escaping (_ messageArray: [Message])-> ()) {
        var groupMessageArray = [Message]()
        REF_GROUPS.child(group.groupId).child("messages").observeSingleEvent(of: .value) { (groupMessageSnapshot) in
            guard let groupMessageSnapshot = groupMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for group in groupMessageSnapshot {
                let content = group.childSnapshot(forPath: "content").value as! String
                let senderId = group.childSnapshot(forPath: "senderId").value as! String
                let groupMessage = Message(content: content, senderId: senderId)
                groupMessageArray.append(groupMessage)
            }
            completion(groupMessageArray)
        }
    }
    
    func getAllChatMessages(userId: String, completion: @escaping (_ messageArray: [ChatMessage]) -> ()) {
        var chatMessageArray = [ChatMessage]()
        var addedMessages = [String]()
        REF_CHATS.child((Auth.auth().currentUser?.uid)!).child(userId).observe(.value) { (MessageIdSnapshot) in
            guard let MessageIdSnapshot = MessageIdSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for messageId in MessageIdSnapshot {
                self.REF_MESSAGES.observe(.value, with: { (userMessageSnapshot) in
                    guard let userMessageSnapshot = userMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
                    for message in userMessageSnapshot {
                        if message.key == messageId.key && !addedMessages.contains(messageId.key) {
                            addedMessages.append(messageId.key)
                            let fromId = message.childSnapshot(forPath: "fromId").value as! String
                            let toId = message.childSnapshot(forPath: "toId").value as! String
                            let content = message.childSnapshot(forPath: "content").value as! String
                            let timestamp = message.childSnapshot(forPath: "timestamp").value as! String
                            let chatMessage = ChatMessage(content: content, fromId: fromId, toId: toId, timestamp: timestamp)
                            chatMessageArray.append(chatMessage)
                        }
                    }
                    completion(chatMessageArray)
                })
            }
        }
        
    }
    
    func getChatContactDetails(id: String, completion: @escaping (_ users: [Users])-> ()) {
        var userArray = [Users]()
        var userIdArray = [String]()
        var arrayId = 0
        REF_CHATS.child(id).observe(.value) { (userChatSnapshot) in
            guard let userChatSnapshot = userChatSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for chatUser in userChatSnapshot {
                self.REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
                    arrayId += 1
                    guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
                    for user in userSnapshot {
                        if chatUser.key == user.key && !userIdArray.contains(user.key) {
                            userIdArray.append(user.key)
                            let email = user.childSnapshot(forPath: "email").value as! String
                            let image = user.childSnapshot(forPath: "image").value as! String
                            let name = user.childSnapshot(forPath: "name").value as! String
                            let provider = user.childSnapshot(forPath: "provider").value as! String
                            let currentUser = Users(email: email, name: name, profileImage: image, provider: provider)
                            userArray.append(currentUser)
                        }
                    }
                    if arrayId == userChatSnapshot.count {
                        completion(userArray)
                    }
                }
            }
        }
    }
    
    func getChatContactMessages(id: String, completion: @escaping (_ messages: [ChatMessage])-> ()) {
        var messageArray = [ChatMessage]()
        REF_CHATS.child(id).observe(.value) { (userChatSnapshot) in
            guard let userChatSnapshot = userChatSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for chatUser in userChatSnapshot {
                self.REF_CHATS.child(id).child(chatUser.key).observe(.value, with: { (chatMessagesSnapshot) in
                    guard let chatMessagesSnapshot = chatMessagesSnapshot.children.allObjects as? [DataSnapshot] else { return }
                    let lastMessage = chatMessagesSnapshot[chatMessagesSnapshot.count - 1]
                    self.REF_MESSAGES.child(lastMessage.key).observeSingleEvent(of: .value, with: { (messageSnapshot) in
                        guard let messageSnap = messageSnapshot.value as? [String: AnyObject] else { return }
                        let fromId = messageSnap["fromId"] as! String
                        let toId = messageSnap["toId"] as! String
                        let content = messageSnap["content"] as! String
                        let timestamp = messageSnap["timestamp"] as! String
                        let currentMessage = ChatMessage(content: content, fromId: fromId, toId: toId, timestamp: timestamp)
                        messageArray.append(currentMessage)
                        if messageArray.count == userChatSnapshot.count
                        {
                            completion(messageArray)
                        }
                    })
                })
            }
        }
    }
    
    func getAllContacts(completion: @escaping (_ idArray: [String], _ users: [Users])-> ()) {
        var userArray = [Users]()
        var idArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                idArray.append(user.key)
                let email = user.childSnapshot(forPath: "email").value as! String
                let image = user.childSnapshot(forPath: "image").value as! String
                let name = user.childSnapshot(forPath: "name").value as! String
                let provider = user.childSnapshot(forPath: "provider").value as! String
                let currentUser = Users(email: email, name: name, profileImage: image, provider: provider)
                userArray.append(currentUser)
            }
            completion(idArray, userArray)
        }
    }
    
    func getUserNameAndImage(ForUID uid: String, completion: @escaping (_ username: String, _ image: String, _ imageBackground: String)-> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == uid {
                    var imageBackground: String? = ""
                    let name = user.childSnapshot(forPath: "name").value as! String
                    let image = user.childSnapshot(forPath: "image").value as! String
                    if image.contains("light") {
                        imageBackground = "black"
                    }
                    else if image.contains("dark") {
                        imageBackground = "white"
                    }
                    completion(name, image, imageBackground!)
                }
            }
        }
    }
    
    func getEmail(forSearchQuery query: String, completion: @escaping (_ emailArray: [String])-> ()) {
        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if email.contains(query) && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            completion(emailArray)
        }
    }
    
    func getUserId(username: String, completion: @escaping (_ userId: String)-> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let name = user.childSnapshot(forPath: "name").value as! String
                if name == username {
                    completion(user.key)
                    break
                }
            }
        }
    }
    
    func getIds(forUsernames usernames: [String], completion: @escaping (_ uidarray: [String])-> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            var idArray = [String]()
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if usernames.contains(email) {
                    idArray.append(user.key)
                }
            }
            completion(idArray)
        }
    }
    
    func getEmailsFor(group: Group, completion: @escaping (_ emailArray: [String])-> ()) {
        var emailArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if group.members.contains(user.key) {
                    let email = user.childSnapshot(forPath: "email").value as! String
                    emailArray.append(email)
                }
            }
            completion(emailArray)
        }
    }
    
    func createGroup(withTitle title: String, andDescription description: String, forUserIds ids: [String], completion: @escaping (_ groupCreated: Bool)-> ()) {
        REF_GROUPS.childByAutoId().updateChildValues(["title": title, "description": description, "members": ids])
        completion(true)
    }
    
    func getAllGroups(completion: @escaping (_ groups: [Group])-> ()) {
        var groupArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for group in groupSnapshot {
                let memberArray = group.childSnapshot(forPath: "members").value as! [String]
                if memberArray.contains((Auth.auth().currentUser?.uid)!) {
                    let title = group.childSnapshot(forPath: "title").value as! String
                    let description = group.childSnapshot(forPath: "description").value as! String
                    let membersCount = memberArray.count
                    let groupKey = group.key
                    let group = Group(title: title, description: description, id: groupKey, membersCount: membersCount, members: memberArray)
                    groupArray.append(group)
                }
            }
            completion(groupArray)
        }
    }
    
    func setAvatarName(avatarName: UIImage)
    {
        self.avatarName = avatarName
    }
    
}
