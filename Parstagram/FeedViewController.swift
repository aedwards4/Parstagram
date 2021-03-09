//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Alexis Edwards on 2/22/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var feedTableView: UITableView!

    let refreshControl = UIRefreshControl()
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    var reversePosts = [PFObject]()
    var numPosts = 10
    
    var showsCommentBar = false
    let commentBar = MessageInputBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self

        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        //feedTableView.rowHeight = 455
        
        refreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        feedTableView.refreshControl = refreshControl
        
        //the color of the background
        self.refreshControl.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);

        //the color of the spinner
        self.refreshControl.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        
        feedTableView.indicatorStyle = UIScrollView.IndicatorStyle.white;
        
        feedTableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment saved!")
            } else {
                print("Error saving comment")
            }
        }
        
        feedTableView.reloadData()
        
        // Clear and dismiss the input
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    @objc func loadPosts(){
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.order(byDescending: "createdAt")
        query.limit = numPosts
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                //self.posts.append(contentsOf: posts!)
                self.feedTableView.reloadData()
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
        run(after: 2){
            self.refreshControl.endRefreshing()
        }
        
    }
    
    func run(after wait: TimeInterval, closure: @escaping () -> Void){
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if indexPath.section + 1 == posts.count {
            numPosts = numPosts + 5
            loadPosts()
        }
    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //reversePosts = posts.reversed()
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            
            cell.usernameLabel.text = user.username
            cell.captionUserLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.postImage.af_setImage(withURL: url)
            
            cell.postImage.layer.borderWidth = 1.0
            
            return cell
        } else if indexPath.row <= comments.count{
            let commentCell = feedTableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell

            let comment = comments[indexPath.row - 1]

            if comment["text"] != nil{
                commentCell.commentLabel.text = comment["text"] as? String

                let user = comment["author"] as! PFUser
                commentCell.usernameLabel.text = user.username
            }

            return commentCell
        } else{
            let addCommentCell = feedTableView.dequeueReusableCell(withIdentifier: "AddCommentCell") as! AddCommentCell
            
//            let user = PFUser.current()
//
//            addCommentCell.userNameLabel.text = (user?.username ?? "     ") as String

            
            
            return addCommentCell
        }
        
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginVC
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
        selectedPost = post
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
