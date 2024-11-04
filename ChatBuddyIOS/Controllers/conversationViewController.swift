//
//  conversationViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit

class conversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let IsLoggedIN = UserDefaults.standard.bool(forKey: "logged_in")
        
        if !IsLoggedIN
        {
            guard let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? LoginViewController else {return}
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
            
        }
    }

  
}
