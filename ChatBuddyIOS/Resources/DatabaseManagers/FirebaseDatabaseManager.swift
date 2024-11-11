//
//  FirebaseDatabaseManager.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 6/11/24.
//
import Foundation
import FirebaseDatabase
import FirebaseAuth

final class FirebaseDatabaseManager
{
    static let shared = FirebaseDatabaseManager()
    
    private var database_ref = Database.database().reference()
}


extension FirebaseDatabaseManager
{
    private func safeEmailAdress(_emailAddress:String) -> String
    {
        var safe_email: String
        
        safe_email = _emailAddress.replacingOccurrences(of: "@", with: "-")
        safe_email = safe_email.replacingOccurrences(of: ".", with: "-")
        
        return safe_email
    }
    
    public func insertUser(with user: ChatAppUser) {
        
        let safeEmail = safeEmailAdress(_emailAddress: user.emailAddress)
        let userRef = self.database_ref.child("users").child(safeEmail)
        
        // Check if the user already exists
        userRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("User data with this email already exists.")
            } else {
                // Insert new user data
                userRef.setValue([
                    "first_Name": user.firstName,
                    "last_Name": user.lastName,
                    "user_Name": user.userName
                ]) { error, _ in
                    if let error = error {
                        print("Error saving data to database: \(error)")
                    } else {
                        print("Data saved successfully in Database!")
                    }
                }
            }
        }
    }
    
    
    public func saveProfileURL(imageUrl: String, forUser userEmailAddress: String) {
        
        let safeEmail = safeEmailAdress(_emailAddress: userEmailAddress)
        let userRef = self.database_ref.child("users").child(safeEmail)
        
        
        userRef.updateChildValues([
            "profileURl": imageUrl
        ]) { error, _ in
            if let error = error {
                print("Error saving URL to Firebase: \(error.localizedDescription)")
            } else {
                print("Image URL saved successfully to Firebase!")
            }
        }
    }
    
    
    public func fetchUserName(with userEmailAddress: String, completion: @escaping (String?) -> Void ) {
        
        let safeEmail = safeEmailAdress(_emailAddress: userEmailAddress)
        let userRef = self.database_ref.child("users").child(safeEmail)
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            // Check if the snapshot contains valid data
            guard let userData = snapshot.value as? [String: Any] else {
                print("User data not found")
                completion(nil)
                return
            }
            
            // Extract the user name
            guard let userName = userData["user_Name"] as? String else {
                print("userName not found")
                completion(nil)
                return
            }
            
            // Return the userName
            completion(userName)
        }
    }
    
    public func fetchUserProfileURL(with userEmailAddress: String, completion: @escaping (String?) -> Void) {
        let safeEmail = safeEmailAdress(_emailAddress: userEmailAddress)
        let userRef = self.database_ref.child("users").child(safeEmail)
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            // Check if the snapshot contains valid data
            guard let userData = snapshot.value as? [String: Any] else {
                print("User data not found")
                completion(nil)
                return
            }
            
            // Extract the profile image URL
            guard let profileImageURL = userData["profileURl"] as? String else {
                print("Profile URL not found")
                completion(nil)
                return
            }
            
            // Return the profile image URL
            completion(profileImageURL)
        }
    }


    public func GetAllUsers(completion: @escaping ([UserData]?) -> Void) {
     
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            print("current user not found")
            completion(nil)
            return
        }
        
        let currentUserEmail = safeEmailAdress(_emailAddress: email)
        
        print(currentUserEmail)
        
        let userRef = self.database_ref.child("users")
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard let usersData = snapshot.value as? [String: [String: Any]] else {
                print("Users data not found")
                completion(nil)
                return
            }
            
            // Array to hold filtered user data
            var users: [UserData] = []
            
            for (user, userData) in usersData {
                if user == currentUserEmail {
                    continue
                } else {
                    if let userName = userData["user_Name"] as? String,
                       let profileUrl = userData["profileURl"] as? String {
                        // Add only userName and profileUrl to the users array
                        users.append(UserData(userEmail: user, userName: userName, userProfileUrl: profileUrl))
                    }
                }
            }
            
           // print(users)
            completion(users)
        }
    }


    
}
