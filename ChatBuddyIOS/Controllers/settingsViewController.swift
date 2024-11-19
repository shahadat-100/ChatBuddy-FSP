//
//  settingsViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 7/11/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn


class settingsViewController: UIViewController {

    @IBOutlet weak var uitableview: UITableView!
    
    let settingNames = ["Language","Switch Accounts","About","Terms & Conditions","Privacy Policy","Rate This App","Share This App"]
    
    let settingIcons = ["Language","Switch Accounts","About","Terms & Conditions","Privacy Policy","Rate This App","Share This App"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uitableview.dataSource = self
        uitableview.delegate = self
        uitableview.register(UINib(nibName: "settingsTableCell", bundle: nil), forCellReuseIdentifier: "settingsTableCell")
        
       
    }
    

    @IBAction func logOutButton(_ sender: UIButton) {

        logOut()
    }
    

}

extension settingsViewController
{
    private func logOut()
    {
        let alert = UIAlertController(title: "Do You Want To LogOut?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { UIAlertAction in
           
            
            // gmail log out/sing out
            GIDSignIn.sharedInstance.signOut()
            print("sccesfully looged out from gmail")
            // firebasae Singout
            do
            {
                try   FirebaseAuth.Auth.auth().signOut()
                print("sccesfully looged out from firebase")
                
                // navigate to login page
                guard let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? LoginViewController else {return}
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false)
                
            }catch let error
            {
                print(error)
            }
        }))
        self.present(alert, animated: true)
    }
}


extension settingsViewController :  UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        guard let cell = uitableview.dequeueReusableCell(withIdentifier: "settingsTableCell") as? settingsTableCell else {return UITableViewCell()}
        cell.uiimageView.image = UIImage(named: settingIcons[indexPath.row])
        cell.lable.text = settingNames[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return uitableview.frame.size.height / CGFloat(Float(settingNames.count))
    }
    
    
}


