//
//  sideManuViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 8/11/24.
//

import UIKit

class sideManuViewController: UIViewController {

    @IBOutlet weak var darkmoodSwitch: UISwitch!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var uitbaleview: UITableView!

    let list = ["Chats","Edit Profile","Frirnd Rrequest","Blocked Users","Profile Privacy"]
    
    let icon = ["Chats","Edit Profile","Frirnd Rrequest","Blocked Users","Profile Privacy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uitbaleview.dataSource = self
        uitbaleview.delegate = self
        uitbaleview.register(UINib(nibName: "sidebarTableviewCell", bundle: nil), forCellReuseIdentifier: "sidebarTableviewCell")
        
    }

}

extension sideManuViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = uitbaleview.dequeueReusableCell(withIdentifier: "sidebarTableviewCell") as? sidebarTableviewCell else { return UITableViewCell()}
        cell.uiimgview.image = UIImage(named: icon[indexPath.row])
        cell.uilbl.text = list[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return uitbaleview.frame.size.height / 6
        
        
    }
    
}
