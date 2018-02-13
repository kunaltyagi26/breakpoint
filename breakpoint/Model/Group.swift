//
//  Group.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 03/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import Foundation

class Group {
    private var _groupTitle: String
    private var _groupDescription: String
    private var _groupId: String
    private var _membersCount: Int
    private var _members: [String]
    
    var groupTitle: String {
        return _groupTitle
    }
    
    var groupDesciption: String {
        return _groupDescription
    }
    
    var groupId: String {
        return _groupId
    }
    
    var membersCount: Int {
        return _membersCount
    }
    
    var members: [String] {
        return _members
    }
    
    init(title: String, description: String, id: String, membersCount: Int, members: [String]) {
        self._groupTitle = title
        self._groupDescription = description
        self._groupId = id
        self._membersCount = membersCount
        self._members = members
    }
}
