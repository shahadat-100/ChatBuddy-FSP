//
//  searchTableViewCell.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 11/11/24.
//

import UIKit

class searchTableViewCell: UITableViewCell {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
           super.layoutSubviews()
           
           // Apply rounded corner
           userPic.layer.cornerRadius = userPic.frame.size.width / 2
           userPic.clipsToBounds = true
       }
    
}
