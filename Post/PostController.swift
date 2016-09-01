//
//  PostController.swift
//  Post
//
//  Created by Joseph Hansen on 8/30/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import Foundation

class PostController {
    
    static let sharedController = PostController()
    
    static let baseURL = NSURL(string: "https://devmtn-post.firebaseio.com/posts")
    static let endpoint = baseURL?.URLByAppendingPathExtension("json")
    
    weak var delegate: PostControllerDelegate?
    
    
    var posts: [Post] = [] {
        didSet {
            delegate?.postsUpdated(posts)
        }
    }
    
    
    init() {
        fetchPosts()
    }
    
    func addPost(username: String, text: String, completion: ((success: Bool) -> Void)? = nil) {
        let post = Post(username: username, text: text)
        guard let requestURL = post.endpoint else {fatalError("URL optional is nil") }
        
        NetworkController.performRequestForURL(requestURL, httpMethod: .Put, urlParameters: nil, body: post.jsonData) { (data, error) in
            guard let data = data,
                responseDataString = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                    print("no data Found")
                    return
            }
            var success = false
            defer { completion?(success: success) }
            if error != nil {
                print("Error \(error!) : \(responseDataString)")
            } else {
                print("Successfully saved data to endpoint")
                success = true
            }
        }
        
        fetchPosts()
    }
    
    func fetchPosts(reset reset: Bool = true, completion: ((newPosts: [Post]) -> Void)? = nil) {
        guard let requestURL = PostController.endpoint else {fatalError("Post Endpoint url failed")}
        let queryEndInterval = reset ? NSDate().timeIntervalSince1970: posts.last?.timestamp ?? NSDate().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast" : "15"]
        
        
        NetworkController.performRequestForURL(requestURL, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
            guard let data = data,
                responseDataString = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                    print("Error: No Data Found /n\(error?.localizedDescription)")
                    if let completion = completion {
                        completion(newPosts: [])
                    }
                    return
            }
            
            guard let postDictionaries = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? [String: [String: AnyObject]] else {
                print("Error, Unable to Serialize JSON: \(responseDataString)")
                if let completion = completion {
                    completion(newPosts: [])
                }
                return
            }
            
            let posts = postDictionaries.flatMap({Post(dictionary: $0.1, identifier: $0.0)})
            let sortedPosts = posts.sort({$0.0.timestamp > $0.1.timestamp})
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.appendContentsOf(sortedPosts)
                }
                if let completion = completion {
                    completion(newPosts: sortedPosts)
                }
                return
            })
            for post in posts {
                print(post.text)
                print(post.queryTimestamp)
                
            }
        }
    }
}

protocol PostControllerDelegate: class {
    func postsUpdated(posts: [Post])
}

