//
//  conversationViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit
import FirebaseAuth

class conversationViewController: UIViewController {

    @IBOutlet weak var sidebarView: UIView!
    var flag = false
    override func viewDidLoad() {
        super.viewDidLoad()

        sidebarView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        is_UserSingedIn()
   
    }
    
    
    
    private func is_UserSingedIn()
    {
        if FirebaseAuth.Auth.auth().currentUser == nil
        {
            guard let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? LoginViewController else {return}
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
            
        }
    }

    @IBAction func sidebarButton(_ sender: UIBarButtonItem) {
        
        if !flag{
           
            showSideBarViewWithAnimation()
            flag = true
        }
        else
        {
            hideSideBarViewWithAnimation()
            flag = false
        }
       
    }
    
    
    // Function to animate showing the view from left to right
    private  func showSideBarViewWithAnimation() {
        // Set the initial position off-screen to the left
        sidebarView.transform = CGAffineTransform(translationX: -sidebarView.frame.width, y: 0)
        sidebarView.isHidden = false  // Make the view visible before animating
        
        // Animate sliding in from left to right
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.sidebarView.transform = .identity  // Move it to its original position
        })
    }

    // Function to animate hiding the view from right to left
    private func hideSideBarViewWithAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            // Move the view off-screen to the left
            self.sidebarView.transform = CGAffineTransform(translationX: -self.sidebarView.frame.width, y: 0)
        }) { action in
            self.sidebarView.isHidden = true  // Hide the view after the animation completes
        }
    }
}
