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
    
    public private(set) var avatarName = ""
    
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
    
    func getUserNameAndImage(ForUID uid: String, completion: @escaping (_ username: String, _ image: String)-> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == uid {
                    let name = user.childSnapshot(forPath: "name").value as! String
                    let image = user.childSnapshot(forPath: "image").value as! String
                    completion(name, image)
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
    
    func setAvatarName(avatarName: String)
    {
        self.avatarName = avatarName
    }
}
