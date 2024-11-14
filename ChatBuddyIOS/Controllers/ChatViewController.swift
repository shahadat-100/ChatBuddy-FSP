//
//  ChatViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 8/11/24.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseAuth

// Define Message and Sender types
struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    func messageKindString() -> String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}


struct Sender: SenderType {
    
    public var senderId: String
    public var displayName: String
    public var photoURL: String
}

class ChatViewController: MessagesViewController {
    
    public var isNewConversation: Bool = false
    public var otherUserEmail: String
    public var otherUserPRofileUrl : String
    
    private var messages = [Message]()
    private var selfSender: Sender?
    
    init(with email: String,with _url: String) {
        
        self.otherUserEmail = email
        self.otherUserPRofileUrl = _url
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safely unwrapping currentUserEmail and initializing selfSender
        guard let currentUserEmail = FirebaseAuth.Auth.auth().currentUser?.email else
        {
            print("User is not authenticated.")
            return
        }
        
        // Initialize selfSender
        self.selfSender = Sender(senderId: currentUserEmail, displayName: "", photoURL: "")
        
        // Setting the delegates for MessageKit
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        messagesCollectionView.reloadData()
    }
}

// MARK: - MessageKit Data Source, Layout, and Display Delegates
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    var currentSender: SenderType {
        // If selfSender is nil, create a fallback sender to avoid crashes
        guard let sender = selfSender else {
            return Sender(senderId: "unknown", displayName: "Unknown", photoURL: "")
        }
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // Check if the message text is not empty and selfSender is initialized and messageID is created
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty,
              let selfSender = self.selfSender,
              let messageID = createMessageID() else {
            return
        }
        
        // Clear the input bar
        inputBar.inputTextView.text = ""
        
        let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
        
        if isNewConversation {
            // Create a new conversation in the database
            FirebaseDatabaseManager.shared.createNewConversation(with: otherUserEmail,name: self.title ?? "user",profileURL:otherUserPRofileUrl,firstMessage: message)
            { success in
                if success
                {
                    print("Message sent successfully")
                }
                else
                {
                    print("Message not sent!")
                }
            }
        }
        else
        {
            // Append to existing conversation data
        }
    }
}

extension ChatViewController {
    
    // Method to create a unique message ID based on email and the current date
    private func createMessageID() -> String? {
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            return nil
        }
        let currentUserEmail = FirebaseDatabaseManager.shared.safeEmailAdress(_emailAddress: email)
        
        
        // Take the first 3 characters of each safe email for abbreviation
        let currentUserName = String(currentUserEmail.prefix(3))
        let otherUserName = String(otherUserEmail.prefix(3))
        
        // Generate a short UUID (using the first 6 characters of a UUID string)
        let shortUUID = UUID().uuidString.prefix(6)
        
        // Create a new identifier combining emails and UUID
        let newIdentifier = "\(otherUserName)_\(currentUserName)_\(shortUUID)"
        
        return newIdentifier
    }
}



