//
//  PostController.swift
//  Post
//
//  Created by Joseph Hansen on 8/30/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import Foundation

class PostController {
    
    static let baseURL = NSURL(string: "https://devmtn-post.firebaseio.com/posts")
    
    
    static var posts: [Post] = []
    
    static func fetchPosts(completion: (posts: [Post]?) -> Void) {
        guard let url = baseURL?.URLByAppendingPathExtension("json") else {
            print("Error No URL Found")
            completion(posts: [])
            return
        }
        
        NetworkController.performRequestForURL(url, httpMethod: .Get) { (data, error) in
            guard let data = data,
                responseDataString = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                    print("Error: No Data Found /n\(error?.localizedDescription)")
                    completion(posts: [])
                    return
            }
            
            guard let postDictionaries = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? [String: [String: AnyObject]] else {
                print("Error, Unable to Serialize JSON: \(responseDataString)")
                completion(posts: [])
                return
            }
            
            let posts = postDictionaries.flatMap({Post(dictionary: $0.1, identifier: $0.0)})
            let sortedPosts = posts.sort({$0.0.timestamp > $0.1.timestamp})
            self.posts = sortedPosts
            completion(posts: sortedPosts)
            
            }
        
        }
        
        
        
        
        
    }
    
}
