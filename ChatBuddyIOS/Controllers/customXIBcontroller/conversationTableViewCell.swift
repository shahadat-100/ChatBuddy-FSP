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
    @IBOutlet weak var messeageLbl: UILabel!
    @IBOutlet weak var date: UILabel!
    
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
        uimge.layer.cornerRadius = uimge.frame.size.width / 2
        uimge.clipsToBounds = true
        
       }
}
