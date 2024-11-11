//
//  userData.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 11/11/24.
//

import Foundation

class UserData
{
    let userEmail : String
    let userName : String
    let userProfileUrl : String
    
    init(userEmail: String, userName: String, userProfileUrl: String) {
        self.userEmail = userEmail
        self.userName = userName
        self.userProfileUrl = userProfileUrl
    }
}
