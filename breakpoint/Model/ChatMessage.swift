//
//  ChatMessage.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 15/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import Foundation

class ChatMessage {
    private var _content: String
    private var _fromId: String
    private var _toId: String
    private var _timestamp: String
    
    var content: String {
        return _content
    }
    
    var fromId: String {
        return _fromId
    }
    
    var toId: String {
        return _toId
    }
    
    var timestamp: String {
        return _timestamp
    }
    
    init(content: String, fromId: String, toId: String, timestamp: String) {
        self._content = content
        self._fromId = fromId
        self._toId = toId
        self._timestamp = timestamp
    }
}
