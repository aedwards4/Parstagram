//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Alexis Edwards on 2/22/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var feedTableView: UITableView!

    let refreshControl = UIRefreshControl()
    
    var posts = [PFObject]()
    var reversePosts = [PFObject]()
    var numPosts = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
    }
    
    @objc func loadPosts(){
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
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
    
    func loadMorePosts(){
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        numPosts = numPosts + 5
        query.limit = numPosts
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.feedTableView.reloadData()
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        reversePosts = posts.reversed()
        let post = reversePosts[indexPath.section]
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
        } else {
            let commentCell = feedTableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            return commentCell
        }
        
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginVC
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if (indexPath.row % 2 == 0){
//            return 455
//        } else{
//            return 50
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comments")
        
        post.saveInBackground { (success, error) in
            if success{
                print("Comment saved!")
            } else {
                print("Error saving comment")
            }
        }
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
