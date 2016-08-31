//
//  PostListTableViewController.swift
//  Post
//
//  Created by Joseph Hansen on 8/30/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, PostControllerDelegate {
    
    //    @IBOutlet weak var refreshControlOutlet: UIRefreshControl!
    
    
    @IBOutlet weak var refreshControlOutlet: UIRefreshControl!
    
    @IBAction func refreshControlPulled(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        postController.fetchPosts { (posts) in
            sender.endRefreshing()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    @IBAction func addButtonTapped(sender: AnyObject) {
        presentNewPostAlert()
    }
    
    let postController = PostController()
    
    var posts: [Post] = [] {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                
            })
        }
    }
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .Alert)
        var usernameTextField: UITextField?
        var messageTextField: UITextField?
        
        alertController.addTextFieldWithConfigurationHandler { (usernameField) in
            usernameField.placeholder = "Display Name"
            usernameTextField = usernameField
        }
        alertController.addTextFieldWithConfigurationHandler { (messageField) in
            messageField.placeholder = "Enter Text"
            messageTextField = messageField
        }
        
        let postAction = UIAlertAction(title: "Post", style: .Default) { (action) in
            guard let username = usernameTextField?.text where !username.isEmpty,
            let text = messageTextField?.text where !text.isEmpty else {
                self.presentErrorAlert()
                return
            }
            self.postController.addPost(username, text: text)
        }
        alertController.addAction(postAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Oh no", message: "Possible network connectivity issues, please try again", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row+1 == postController.posts.count {
            postController.fetchPosts(reset: false, completion: { (newPosts) in
                if !newPosts.isEmpty {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                postController.delegate = self
        
        tableView.estimatedRowHeight = 80
//        postController.addPost("Joseph", text: "Hello")
        
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func postsUpdated(posts: [Post]) {
        tableView.reloadData()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postController.posts.count
    }
    
    
    func formattedStringFromDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        let post  = postController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        
        let date = NSDate(timeIntervalSince1970: post.timestamp)
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(formattedStringFromDate(date)))"
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
