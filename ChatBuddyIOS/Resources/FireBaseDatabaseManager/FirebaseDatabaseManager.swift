//
//  FirebaseDatabaseManager.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 6/11/24.
//
import Foundation
import FirebaseDatabase


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
     
}
