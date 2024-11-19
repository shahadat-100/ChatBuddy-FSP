//
//  conversationViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit
import FirebaseAuth
import SDWebImage


class conversationViewController: UIViewController {
    
    @IBOutlet weak var sidebarView: UIView!
    @IBOutlet weak var uitableview: UITableView!
    @IBOutlet weak var sidebarConteinarview: UIView!
    @IBOutlet weak var sidebarButton: UIBarButtonItem!
    
    var conversationslist = [ConversationList]()
    
    
    var sideBar_flag = false
    
    private var tapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        sidebarView.isHidden = true
        
        uitableview.dataSource = self
        uitableview.delegate = self
        uitableview.register(UINib(nibName: "conversationTableViewCell", bundle: nil), forCellReuseIdentifier: "conversationTableViewCell")
        
        stratListenigForConversations()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        is_UserSingedIn()
        stratListenigForConversations()

    }
    
    @IBAction func sidebarButton(_ sender: UIBarButtonItem) {
        
        if !sideBar_flag{
            
            addGesture()
            showSideBarViewWithAnimation()
            sideBar_flag = true
        }
        else
        {
            hideSideBarViewWithAnimation()
            removeGesture()
            sideBar_flag = false
        }
        
    }
    
}

extension conversationViewController
{
    
    private func stratListenigForConversations()
    {
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else
        {
            return
        }
        let currentEmail = FirebaseDatabaseManager.shared.safeEmailAdress(_emailAddress: email)
        
        FirebaseDatabaseManager.shared.getAllFriendlist(for: currentEmail) { conversations in
            guard let conversations = conversations, !conversations.isEmpty else
            {
                print("No conversations found for \(currentEmail) ")
                return
            }
            self.conversationslist = conversations
            DispatchQueue.main.async {
                self.uitableview.reloadData()
                
            }
            
        }
        
        
    }
    
    
    private func addGesture() {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
                if let gesture = tapGesture {
                    self.view.addGestureRecognizer(gesture)
                }
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        
        // Get the touch location within the main view
        let touchLocation = gesture.location(in: self.view)
        let sidebarFrame = self.sidebarView.frame
        
        // Check if the touch is outside the sidebar
        if !sidebarFrame.contains(touchLocation) {
            hideSideBarViewWithAnimation()
            removeGesture()
            sideBar_flag = false
        }
    }
    
    private func removeGesture() {
            // Remove the gesture recognizer
            if let gesture = tapGesture {
                self.view.removeGestureRecognizer(gesture)
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
        
        sidebarButton.tintColor = .color1
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
        
        sidebarButton.tintColor = .color
        
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
        return conversationslist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = uitableview.dequeueReusableCell(withIdentifier: "conversationTableViewCell") as? conversationTableViewCell
        else {return UITableViewCell()}
        
        let user = conversationslist[indexPath.row]
        let lastIndx  =  user.conversation.count - 1
        cell.UserName.text = user.name
        if user.conversation[lastIndx].type == "photo"
        {
            if user.conversation[lastIndx].senderEmail == user.UserEmail{
                cell.messeageLbl.text = "\(user.name) sent a photo"
            }
            else
            {
                cell.messeageLbl.text = "You sent a photo"
            }
        }
        else
        {
            if user.conversation[lastIndx].senderEmail == user.UserEmail{
                cell.messeageLbl.text = user.conversation[lastIndx].latestMessage.text
            }
            else
            {
                cell.messeageLbl.text = "You : \(user.conversation[lastIndx].latestMessage.text)"
            }
        }
        cell.date.text = user.conversation[lastIndx].latestMessage.time
        if let imageUrl = URL(string: user.profileUrl)
        {
            DispatchQueue.main.async {
                cell.uimge.sd_setImage(with: imageUrl)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return uitableview.frame.size.height / 8
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = conversationslist[indexPath.row]
        let vc = ChatViewController(email: user.UserEmail, _url: user.profileUrl, userName: user.name)
        
        vc.title = user.name
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


/*  */
