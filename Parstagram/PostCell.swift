//
//  PostCell.swift
//  Parstagram
//
//  Created by Alexis Edwards on 2/22/21.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
