//
//  NewConversationsViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit

class NewConversationsViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.becomeFirstResponder()
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search New Friends"
        searchController.searchBar.enablesReturnKeyAutomatically = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
      
    }

}

extension NewConversationsViewController:UISearchControllerDelegate,UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let Friend = searchController.searchBar.text , !Friend.isEmpty else { return}
        print(Friend)
        
    }
    
}
