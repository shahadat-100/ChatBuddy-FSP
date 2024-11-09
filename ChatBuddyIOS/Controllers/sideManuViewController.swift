//
//  sideManuViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 8/11/24.
//

import UIKit
import FirebaseAuth

class sideManuViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var uitbaleview: UITableView!
    @IBOutlet weak var oneCellTableView: UITableView!
    
    let list = ["Chats","Frirnd Rrequest","Blocked Users","Profile Privacy"]
    
    let icon = ["Chats","Frirnd Rrequest","Blocked Users","Profile Privacy"]
    
    var  currentUserEmail : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uitbaleview.dataSource = self
        uitbaleview.delegate = self
        uitbaleview.register(UINib(nibName: "sidebarTableviewCell", bundle: nil), forCellReuseIdentifier: "sidebarTableviewCell")
        
        oneCellTableView.dataSource = self
        oneCellTableView.delegate = self
        oneCellTableView.register(UINib(nibName: "OneTableCell", bundle: nil), forCellReuseIdentifier: "OneTableCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        setUserProfile()
        
    }
    
    private func setUserProfile()
    {
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else
        {
            return
        }
        currentUserEmail = email
        
        FirebaseDatabaseManager.shared.fetchUserName(with: currentUserEmail) {[weak self] userName in
            
            guard let userName = userName else
            {
                print("User name not found")
                return
            }
            
            self?.name.text = userName
            self?.email.text = self?.currentUserEmail
        }
    }

}

extension sideManuViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == oneCellTableView
        {
            return 1
        }
        return  list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == oneCellTableView
        {
            guard let cell = oneCellTableView.dequeueReusableCell(withIdentifier: "OneTableCell") as? OneTableCell else { return UITableViewCell()}
            return cell
            
        }
        guard let cell = uitbaleview.dequeueReusableCell(withIdentifier: "sidebarTableviewCell") as? sidebarTableviewCell else { return UITableViewCell()}
        cell.uiimgview.image = UIImage(named: icon[indexPath.row])
        cell.uilbl.text = list[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == oneCellTableView
        {
            return oneCellTableView.frame.height
        }
        return uitbaleview.frame.size.height / 6
        
        
    }
    
}
