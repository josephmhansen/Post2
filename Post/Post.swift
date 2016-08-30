//
//  Post.swift
//  Post
//
//  Created by Joseph Hansen on 8/30/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import Foundation

struct Post {
    
    private let kUsername = "username"
    private let kText = "text"
    private let kTimestamp = "timestamp"
    private let kIdentifier = "identifier"
    
    let username: String
    let text: String
    let timestamp: NSTimeInterval
    let identifier: NSUUID
    
    
    init(username: String, text: String, identifier: NSUUID = NSUUID()) {
        self.username = username
        self.text = text
        self.timestamp = NSDate().timeIntervalSince1970
        self.identifier = identifier
    }
    
    init?(dictionary: [String: AnyObject], identifier: String) {
        guard let username = dictionary[kUsername] as? String,
        text = dictionary[kText] as? String,
        timestamp = dictionary[kTimestamp] as? Double,
        identifier = NSUUID(UUIDString: identifier) else { return nil }
        
        self.username = username
        self.text = text
        self.timestamp = NSTimeInterval(floatLiteral: timestamp)
        self.identifier = identifier
        
    }
    
    var jsonValue: [String: AnyObject]{
        return [kUsername: username, kTimestamp: timestamp, kText : text]
    }
    var queryTimestamp: NSTimeInterval {
        return timestamp - 0.000001
    }
    var jsonData: NSData? {
        return try? NSJSONSerialization.dataWithJSONObject(jsonValue, options: .PrettyPrinted)
    }
    var endpoint: NSURL? {
        return PostController.baseURL?.URLByAppendingPathComponent(self.identifier.UUIDString).URLByAppendingPathExtension("json")
    }
}
