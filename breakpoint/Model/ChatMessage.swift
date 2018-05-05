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
    private var _toId: String?
    private var _timestamp: String
    private var _imageUrl: String?
    private var _imageWidth: NSNumber?
    private var _imageHeight: NSNumber?
    private var _videoUrl: String?
    
    var content: String? {
        return _content
    }
    
    var fromId: String {
        return _fromId
    }
    
    var toId: String? {
        return _toId
    }
    
    var timestamp: String {
        return _timestamp
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var imageWidth: NSNumber? {
        return _imageWidth
    }
    
    var imageHeight: NSNumber? {
        return _imageHeight
    }
    
    var videoUrl: String? {
        return _videoUrl
    }
    
    init(content: String?, imageUrl: String?, imageWidth: NSNumber?, imageHeight: NSNumber?, videoUrl: String?, fromId: String, toId: String?, timestamp: String) {
        if content != nil {
            self._content = content!
        }
        if imageUrl != nil {
            self._imageUrl = imageUrl!
            self._imageWidth = imageWidth
            self._imageHeight = imageHeight
        }
        if videoUrl != nil {
            self._videoUrl = videoUrl!
        }
        if toId != nil {
            self._toId = toId
        }
        self._fromId = fromId
        self._timestamp = timestamp
    }
}
