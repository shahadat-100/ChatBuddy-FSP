//
//  NewConversationsViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit
import SDWebImage

class NewConversationsViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var uitableview: UITableView!
   
    //var searching = false
    var filterUsers = [UserData]()
    var _usersList = [UserData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        uitableview.dataSource = self
        uitableview.delegate = self
        uitableview.register(UINib(nibName: "searchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchTableViewCell")
        
        setUpsearchController()
        userSetUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        filterUsers.removeAll()
        uitableview.reloadData()
        searchController.searchBar.placeholder = "Search Friends Here!"
    }

}

extension NewConversationsViewController
{
    private func userSetUp() {
        
        FirebaseDatabaseManager.shared.GetAllUsers { users in
           
            guard let users = users, !users.isEmpty else {
               
                print("No users found or user list is empty.")
                return
            }
            
            for user in users {
                self._usersList.append(user)
            }
            
        }
    }
   
    
    private func setUpsearchController()
    {
        searchController.becomeFirstResponder()
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Friends Here!"
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = .done
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
    }
}

extension NewConversationsViewController:UISearchControllerDelegate,UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let userName = searchController.searchBar.text , !userName.isEmpty else { return }
        
        filterUsers.removeAll()
        
        for user in _usersList
        {
            if user.userName.lowercased().contains(userName.lowercased())
            {
                filterUsers.append(user)
            }
        }
        uitableview.reloadData()
    }
    
}

extension NewConversationsViewController:UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filterUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = uitableview.dequeueReusableCell(withIdentifier: "searchTableViewCell") as? searchTableViewCell else
        {
            return UITableViewCell()
        }
        let row = indexPath.row
        cell.userEmail.text = filterUsers[row].userEmail
        cell.userName.text = filterUsers[row].userName
        if let imageUrl = URL(string: filterUsers[row].userProfileUrl)
        {
            // Load image asynchronously using SDWebImage
            DispatchQueue.main.async {
                cell.userPic.sd_setImage(with: imageUrl)
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return uitableview.frame.height / 8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let targerUserData =  filterUsers[indexPath.row]
        let vc = ChatViewController(email: targerUserData.userEmail, _url: targerUserData.userProfileUrl, userName: targerUserData.userName)
        
        vc.title = targerUserData.userName
        vc.isNewConversation = true
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.hidesBottomBarWhenPushed = true
        searchController.searchBar.text = ""
        navigationController?.pushViewController(vc, animated: true)
        
       
    }
    
}

/*
*/
