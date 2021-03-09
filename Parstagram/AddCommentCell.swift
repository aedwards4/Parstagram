//
//  AddCommentCell.swift
//  Parstagram
//
//  Created by Alexis Edwards on 3/8/21.
//

import UIKit

class AddCommentCell: UITableViewCell {

    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var userNameLabel: UITextField!
    @IBOutlet weak var addCommentTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
