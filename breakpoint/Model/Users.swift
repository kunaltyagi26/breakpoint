//
//  Users.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 14/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import Foundation

class Users {
    private var _email: String
    private var _name: String
    private var _profileImage: String
    private var _provider: String
    
    var email: String {
        return _email
    }
    
    var name: String {
        return _name
    }
    
    var profileImage: String {
        return _profileImage
    }
    
    var provider: String {
        return _provider
    }
    
    init(email: String, name: String, profileImage: String, provider: String) {
        self._email = email
        self._name = name
        self._profileImage = profileImage
        self._provider = provider
    }
}
