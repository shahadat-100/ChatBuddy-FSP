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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logOutButton(_ sender: UIButton) {
        
        // gmail log out/sing out
        GIDSignIn.sharedInstance.signOut()
        print("sccesfully looged out from gmail")
        // firebasae Singout
        do
        {
            try   FirebaseAuth.Auth.auth().signOut()
            print("sccesfully looged out from firebase")
            guard let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? LoginViewController else {return}
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
            
        }catch let error
        {
            print(error)
        }
    }
    

}
