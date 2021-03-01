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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        feedTableView.rowHeight = 455
        
        refreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        feedTableView.refreshControl = refreshControl
        
        //the color of the background
        self.refreshControl.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);

        //the color of the spinner
        self.refreshControl.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        
    }
    
    @objc func loadPosts(){
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = 10
        
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
        query.limit = 5
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts.append(contentsOf: posts!)
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
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.postImage.af_setImage(withURL: url)
        
        cell.postImage.layer.borderWidth = 1.0
        
        return cell
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
