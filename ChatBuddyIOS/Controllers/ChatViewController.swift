//
//  ChatViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 8/11/24.
//

import UIKit
import MessageKit

// Define Message and Sender types
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}

class ChatViewController: MessagesViewController {
    
    // Messages data array
    private var messages = [Message]()
    
    // The current user
    private let selfSender = Sender(senderId: "1", displayName: "hello aryan", photoURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sample messages for testing
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("hello mello")))
        
        messages.append(Message(sender: selfSender,
                                messageId: "2",
                                sentDate: Date(),
                                kind: .text("hello mello yoyooyoyooyyoyoyo otoootot oototo")))
        
        // Setting the delegates for MessageKit
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messagesCollectionView.reloadData()
       // messagesCollectionView.scrollToLastItem(animated: true)
    }
}

// MARK: - MessageKit Data Source, Layout, and Display Delegates
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    // Current sender for the chat
    var currentSender: any MessageKit.SenderType {
        return selfSender
    }
    
    // Message for item at index path
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    // Number of sections (one per message)
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

}
