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

// MARK: - Account Managment
extension FirebaseDatabaseManager
{
    public func safeEmailAdress(_emailAddress:String) -> String
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
            guard let profileImageURL = userData["profileURl"] as? String else {  // corrected "profileURL" spelling
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
        
        //print(currentUserEmail)
        
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
            completion(users)
        }
    }
    
}

// MARK: - chats managment

extension FirebaseDatabaseManager {
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = .current
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter.string(from: date)
    }
    
    private func getMessageContent(from message: Message) -> String {
        switch message.kind {
        case .text(let messageText):
            return messageText
        case .photo(let mediaItem):
            return mediaItem.url?.absoluteString ?? ""
        case .attributedText(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_), .linkPreview(_), .custom(_):
            return "Undefined message kind  For now!"
        }
    }
    
    
    
    ///Create a new conversation with the target user's email and first message
    public func createNewConversation(with otherUserEmail: String, name: String, profileURL: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        // Get the current user's email, ensuring they're logged in
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            print("Current user not found")
            completion(false)
            return
        }
        // Convert email to a safe format to use as a key
        let currentUserEmail = safeEmailAdress(_emailAddress: email)
        let userRef = self.database_ref.child("users").child(currentUserEmail)
        // Fetch the current user's data from the database
        userRef.observeSingleEvent(of: .value) { snapshot in
            // Ensure the user data exists
            guard var userNode = snapshot.value as? [String: Any] else {
                print("User not found")
                completion(false)
                return
            }
            // Prepare the conversation details
            let messageContent = self.getMessageContent(from: firstMessage)
            let messageDate = self.formatDate(firstMessage.sentDate)
            let messageTime = self.formatTime(firstMessage.sentDate)
            let conversationId = "convo_\(firstMessage.messageId)"
            let newConversation: [String: Any] = [
                "_id": conversationId,
                "_senderEmail" : currentUserEmail,
                "_type": firstMessage.kind.messageKindString(),
                "_latestMassage": [
                    "_time": messageTime,
                    "_date": messageDate,
                    "_isRead": false,
                    "_message": messageContent
                ]
            ]
            // Create the friend details for a new friend
            let friendDetails: [String: Any] = [
                "userName": name,
                "email": otherUserEmail,
                "profileUrl": profileURL,
                "conversations": [newConversation]
            ]
            // Access the FriendList (or create an empty one if it doesn't exist)
            var friendList = userNode["FriendList"] as? [[String: Any]] ?? []
            var friendExists = false
            // Manually loop through the friend list to check if this friend exists
            for i in 0..<friendList.count {
                // Access the current friend's details
                if let friendInfo = friendList[i][name] as? [String: Any],
                   let friendEmail = friendInfo["email"] as? String,
                   friendEmail == otherUserEmail {
                    // Friend exists, so add the new conversation to this friend's conversation list
                    var conversations = friendInfo["conversations"] as? [[String: Any]] ?? []
                    conversations.append(newConversation)
                    
                    // Update the friend's conversation list
                    var updatedFriendInfo = friendInfo
                    updatedFriendInfo["conversations"] = conversations
                    friendList[i][name] = updatedFriendInfo
                    
                    friendExists = true
                    break
                }
            }
            // If the friend doesn't exist, add a new entry for this friend
            if !friendExists {
                friendList.append([name: friendDetails])
            }
            // Update the user node with the new or updated FriendList
            userNode["FriendList"] = friendList
            userRef.setValue(userNode) { error, _ in
                if let error = error {
                    print("Failed to save data:", error)
                    completion(false)
                } else {
                    self.createRepicientConversation(with: otherUserEmail, firstMessage: firstMessage, otherUserEmail: currentUserEmail) { success in
                        if success
                        {
                            completion(true)
                        }
                        else
                        {
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    
    private func createRepicientConversation(with email: String,firstMessage:Message,otherUserEmail:String, completion: @escaping (Bool)-> Void)
    {
        var otherUserName = "",otherUserUrl = ""
        fetchUserName(with: otherUserEmail) { userName in
            
            guard let userName = userName else
            {
                print("??")
                completion(false)
                return
            }
            otherUserName = userName
        }
        
        fetchUserProfileURL(with: otherUserEmail) { url in
            
            guard let url = url else
            {
                print("??")
                completion(false)
                return
            }
            otherUserUrl = url
            
        }
        
        
        let userRef = self.database_ref.child("users").child(email)
        // Fetch the current user's data from the database
        userRef.observeSingleEvent(of: .value) { snapshot in
            // Ensure the user data exists
            guard var userNode = snapshot.value as? [String: Any] else {
                print("User not found")
                completion(false)
                return
            }
            // Prepare the conversation details
            let messageContent = self.getMessageContent(from: firstMessage)
            let messageDate = self.formatDate(firstMessage.sentDate)
            let messageTime = self.formatTime(firstMessage.sentDate)
            let conversationId = "convo_\(firstMessage.messageId)"
            let newConversation: [String: Any] = [
                "_id": conversationId,
                "_senderEmail" : otherUserEmail,
                "_type": firstMessage.kind.messageKindString(),
                "_latestMassage": [
                    "_time": messageTime,
                    "_date": messageDate,
                    "_isRead": false,
                    "_message": messageContent
                ]
            ]
            // Create the friend details for a new friend
            let friendDetails: [String: Any] = [
                "userName": otherUserName,
                "email": otherUserEmail,
                "profileUrl": otherUserUrl,
                "conversations": [newConversation]
            ]
            
            // Access the FriendList (or create an empty one if it doesn't exist)
            var friendList = userNode["FriendList"] as? [[String: Any]] ?? []
            var friendExists = false
            
            // Manually loop through the friend list to check if this friend exists
            for i in 0..<friendList.count {
                // Access the current friend's details
                if let friendInfo = friendList[i][otherUserName] as? [String: Any],
                   let friendEmail = friendInfo["email"] as? String,
                   friendEmail == otherUserEmail {
                    
                    // Friend exists, so add the new conversation to this friend's conversation list
                    var conversations = friendInfo["conversations"] as? [[String: Any]] ?? []
                    conversations.append(newConversation)
                    
                    // Update the friend's conversation list
                    var updatedFriendInfo = friendInfo
                    updatedFriendInfo["conversations"] = conversations
                    friendList[i][otherUserName] = updatedFriendInfo
                    
                    friendExists = true
                    break
                }
            }
            // If the friend doesn't exist, add a new entry for this friend
            if !friendExists {
                friendList.append([otherUserName: friendDetails])
            }
            // Update the user node with the new or updated FriendList
            userNode["FriendList"] = friendList
            userRef.setValue(userNode) { error, _ in
                if let error = error {
                    print("Failed to save data:", error)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    
    public func getAllFriendlist(for email: String, completion: @escaping ([ConversationList]?) -> Void) {
        // Ensure the email is properly escaped to avoid issues with Firebase keys
        let safeEmail = safeEmailAdress(_emailAddress: email)
        
        // Fetch the user's FriendList from Firebase
        database_ref.child("users").child(safeEmail).child("FriendList").observe(.value) { snapshot in
            
            // Handle snapshot to get the friend list data
            guard let friendList = snapshot.value as? [[String: Any]] else {
                print("Error: FriendList not found or has incorrect format.")
                completion(nil)
                return
            }
            
            var conversationsList: [ConversationList] = [] // Array to store all the conversations for the user
            
            // Loop through each friend's data in the FriendList
            for friend in friendList  {
                // Safe unwrapping and better error handling for optional fields
                // print("Friend dictionary keys: \(dictionary.keys)")
                // print("Friend dictionary values: \(dictionary.values)")
                
                guard
                    let friendData = friend.values.first as? [String: Any] ,
                    let conversations = friendData["conversations"] as? [[String: Any]],
                    let otherUserEmail = friendData["email"] as? String,
                    let profileUrl = friendData["profileUrl"] as? String,
                    let name = friendData["userName"] as? String else {
                    print("Skipping friend due to missing or invalid data.")
                    continue
                }
                // Variable to store the latest conversation's last message
                var latestMessage: LattesMessage? = nil
                
                var id : String?
                var _senderEmail:String?
                var type_ :String?
                // Iterate through each conversation for the friend and get the last message
                for conversation in conversations {
                    guard let _id = conversation["_id"] as? String,
                          let senderEmail = conversation["_senderEmail"] as? String,
                          let _type = conversation["_type"] as? String,
                          let latestMessageDict = conversation["_latestMassage"] as? [String: Any],
                          let time = latestMessageDict["_time"] as? String,
                          let date = latestMessageDict["_date"] as? String,
                          let message = latestMessageDict["_message"] as? String,
                          let isRead = latestMessageDict["_isRead"] as? Bool else {
                        print("Skipping conversation due to missing or invalid fields.....")
                        continue
                    }
                    
                    latestMessage = LattesMessage(time: time, date: date, text: message, is_read: isRead)
                    
                    id = _id
                    _senderEmail = senderEmail
                    type_ = _type
                }
                
                // Ensure we found a valid latest message
                guard let _latestMessage = latestMessage,let id = id,let senderEmail = _senderEmail,let typee = type_ else {
                    print("No latest message found for friend \(name).")
                    continue
                }
                // Create the conversation model with the latest message
                let conversationModel = Conversation(id: id,senderEmail:senderEmail,type: typee , latestMessage: _latestMessage)
                
                // Create the conversation list model for the friend
                let conversationListModel = ConversationList(name: name, otherUserEmail: otherUserEmail, profileUrl: profileUrl, conversation: [conversationModel])
                
                // Add the conversation list for the friend to the main list
                conversationsList.append(conversationListModel)
            }
            
            // Return the populated list of all conversations
            
            completion(conversationsList)
        }
    }
    
    
    
    public func getFriendConversations(for email: String, friendName: String, completion: @escaping ([[String: Any]]?,String?) -> Void) {
        // Convert email to a safe format
        let safeEmail = safeEmailAdress(_emailAddress: email)
        
        // Access the specific friend's details in the FriendList
        database_ref.child("users").child(safeEmail).child("FriendList").observe(.value) { snapshot in
            // Check if FriendList exists
            guard let friendList = snapshot.value as? [[String: Any]] else {
                print("Error: FriendList not found or incorrect format")
                completion(nil,nil)
                return
            }
            
            // Loop through the FriendList to find the specific friend by name
            for friend in friendList {
                if let friendDetails = friend[friendName] as? [String: Any],
                   let conversations = friendDetails["conversations"] as? [[String: Any]],
                   let profileUrl = friendDetails["profileUrl"] as? String
                {
                    
                    completion(conversations,profileUrl)
                    return
                }
            }
            // Return the friend's conversations
            print("Error: Friend \(friendName) not found in FriendList")
            completion(nil,nil)
            
        }
    }
    
}



