//
//  conversationTableViewCell.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 8/11/24.
//

import UIKit

class conversationTableViewCell: UITableViewCell {

    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var uimge: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    
        uimge.clipsToBounds = false
        uimge.layer.cornerRadius = uimge.frame.size.width / 2
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
