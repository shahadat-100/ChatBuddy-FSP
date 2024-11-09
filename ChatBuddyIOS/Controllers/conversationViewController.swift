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
    @IBOutlet weak var emptyImgVIew: UIImageView!
    @IBOutlet weak var emptyLvl: UILabel!
    @IBOutlet weak var uitableview: UITableView!
    @IBOutlet weak var sidebarConteinarview: UIView!
    
    var user = ["Person1","Person2","Person1","Person2","Person1","Person2","Person1","Person2","Person1","Person2","Person1","Person2",]
    
    var flag = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sidebarView.isHidden = true
        uitableview.isHidden = true
        
        
        uitableview.dataSource = self
        uitableview.delegate = self
        uitableview.register(UINib(nibName: "conversationTableViewCell", bundle: nil), forCellReuseIdentifier: "conversationTableViewCell")
        
        
        if user.count == 0 && user.isEmpty
        {
            emptyLvl.isHidden = true
            emptyImgVIew.isHidden = true
        }
        
        fatchConversation()
        addGesture()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        is_UserSingedIn()
        
   
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
    
}

extension conversationViewController
{
    
    private func fatchConversation()
    {
        uitableview.isHidden = false
    }
    
    private func addGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
       
        // Get the touch location within the main view
        let touchLocation = gesture.location(in: self.view)
        let sidebarFrame = self.sidebarView.frame
        
        // Check if the touch is outside the sidebar
        if !sidebarFrame.contains(touchLocation) {
            hideSideBarViewWithAnimation()
            flag = false
        }
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
    
    // Function to animate showing the view from left to right
    private  func showSideBarViewWithAnimation() {
        // Set the initial position off-screen to the left
        sidebarView.transform = CGAffineTransform(translationX: -sidebarView.frame.width, y: 0)
        sidebarView.isHidden = false  // Make the view visible before animating
        
        // Animate sliding in from left to right
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.sidebarView.transform = .identity  // Move it to its original position
            self.navigationItem.title = nil
        })
    }

    // Function to animate hiding the view from right to left
    private func hideSideBarViewWithAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            // Move the view off-screen to the left
            self.sidebarView.transform = CGAffineTransform(translationX: -self.sidebarView.frame.width, y: 0)
        }) { action in
            self.sidebarView.isHidden = true  // Hide the view after the animation completes
            self.navigationItem.title = "Chats"
        }
    }
}



extension conversationViewController : UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = uitableview.dequeueReusableCell(withIdentifier: "conversationTableViewCell") as? conversationTableViewCell
        else {return UITableViewCell()}
        cell.UserName.text = user[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return uitableview.frame.size.height / 7
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {return}
//        //let vc = ChatViewController()
//        vc.title = user[indexPath.row]
//        vc.navigationItem.largeTitleDisplayMode = .never
//        vc.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    
}
