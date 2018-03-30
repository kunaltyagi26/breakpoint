//
//  ChatMessage.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 15/03/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import Foundation

class ChatMessage {
    private var _content: String?
    private var _fromId: String
    private var _toId: String
    private var _timestamp: String
    private var _imageUrl: String?
    
    var content: String? {
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
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    init(content: String?, imageUrl: String?, fromId: String, toId: String, timestamp: String) {
        if content != nil {
            self._content = content!
        }
        else {
            self._imageUrl = imageUrl!
        }
        self._fromId = fromId
        self._toId = toId
        self._timestamp = timestamp
    }
}
