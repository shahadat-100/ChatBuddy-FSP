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
import IQKeyboardManagerSwift
import SDWebImage
import PhotosUI

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

struct Media : MediaItem
{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
}

class ChatViewController: MessagesViewController {
    
    public var isNewConversation: Bool = false
    public var otherUserEmail: String
    public var otherUserPRofileUrl : String
    public var friendName : String
    
    private var messages = [Message]()
    private var selfSender: Sender?
    
    init( email: String, _url: String, userName:String) {
        
        self.otherUserEmail = email
        self.otherUserPRofileUrl = _url
        self.friendName = userName
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safely unwrapping currentUserEmail and initializing selfSender
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else
        {
            print("User is not authenticated.")
            return
        }
        var  _currentUserName = ""
        var _currenUserprofileUrl = ""
        let currentUserEmail = FirebaseDatabaseManager.shared.safeEmailAdress(_emailAddress: email)
        
        
        FirebaseDatabaseManager.shared.fetchUserName(with: currentUserEmail) { url in
            guard let url = url
            else{
                print("url is not found.")
                return
            }
            _currenUserprofileUrl = url
        }
        
        FirebaseDatabaseManager.shared.fetchUserName(with:  currentUserEmail) { name in
            guard let name = name
            else{
                print("UserName is not found.")
                return
            }
            _currentUserName = name
        }
        
        // Initialize selfSender
        self.selfSender = Sender(senderId: currentUserEmail, displayName:  _currentUserName, photoURL: _currenUserprofileUrl)
        
        // Setting the delegates for MessageKit
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        messagesCollectionView.reloadData()
        setUpinputBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.isEnabled = false
        listenForMessages()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.isEnabled = true
    }
}

// MARK: - MessageKit Data Source, Layout, and Display Delegates
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate,MessageCellDelegate {
    
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
    
    
    func backgroundColor(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if isFromCurrentSender(message: message)
        {
            return UIColor.color
        }
        else
        {
            return UIColor.color2
        }
    }
    
    func textColor(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return UIColor.color1
    }
    
    
    
    func configureAvatarView(_ avatarView: AvatarView, for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let sender = message.sender as? Sender else { return}
        
        if sender.senderId == otherUserEmail
        {
            if let url = URL(string: sender.photoURL)
            {
                avatarView.sd_setImage(with: url)
            }
        }
        else
        {
            guard let email = FirebaseAuth.Auth.auth().currentUser?.email else
            {
                print("User is not authenticated.")
                return
            }
            let currentUserEmail = FirebaseDatabaseManager.shared.safeEmailAdress(_emailAddress: email)
            
            FirebaseDatabaseManager.shared.fetchUserProfileURL(with: currentUserEmail) { url in
                
                guard let url = url else
                {
                    return
                }
                
                if let url = URL(string: url)
                {
                    
                    avatarView.sd_setImage(with: url)
                }
            }
  
        }
        
    }
    
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else
        {
            return
        }
        
        switch message.kind
        {
        case .photo(let media):
            guard let imageUrl = media.url else
            {
                return
            }
            imageView.sd_setImage(with: imageUrl)
        default:
            break
        }
        
        
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
       // view.endEditing(true)
       // showOptionsMenu(for: cell)
        
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
        
        // Create a  conversation in the database
        FirebaseDatabaseManager.shared.createNewConversation(with: otherUserEmail,name: friendName,profileURL:otherUserPRofileUrl,firstMessage: message)
        { success in
            if success
            {
                print("Message sent successfully")
                self.listenForMessages()
                
            }
            else
            {
                print("Message not sent!")
            }
        }
    }
}

extension ChatViewController {
    
    
    private func setUpinputBarButton()
    {
        let button = InputBarButtonItem()
        let buttonSize = CGSize(width: view.frame.width * 0.08, height: view.frame.width * 0.10) // 8% of the screen width
        button.setSize(buttonSize, animated: false)
        button.setImage(UIImage(named: "gallery"), for: .normal)
        button.addTarget(self, action:#selector(openGalery), for: .touchUpInside)
        messageInputBar.setLeftStackViewWidthConstant(to: view.frame.width * 0.15, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.inputTextView.placeholder = "Type a message..."
    }
    

    @objc func openGalery()
    {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        
        let pickerVc = PHPickerViewController(configuration: config)
        pickerVc.delegate = self
        present(pickerVc, animated: true)
    }
    
    
    
    private func listenForMessages()
    {
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else
        {
            print("User is not authenticated.")
            return
        }
        let currentUserEmail = FirebaseDatabaseManager.shared.safeEmailAdress(_emailAddress: email)
        
        FirebaseDatabaseManager.shared.getFriendConversations(for: currentUserEmail , friendName: friendName) { conversations,url in
            
            guard let conversations = conversations,let url = url else
            {
                print("No conversation and url found")
                return
            }
            
            var newMessage = [Message]()
            
            for conversation in conversations {
                
                if let _messageid = conversation["_id"] as? String,
                   let _senderEmail = conversation["_senderEmail"] as? String,
                   let _type = conversation["_type"] as? String,
                   let latestMessageDict = conversation["_latestMassage"] as? [String: Any],
                   let time = latestMessageDict["_time"] as? String,
                   let date = latestMessageDict["_date"] as? String,
                   let message = latestMessageDict["_message"] as? String
                // ,let isRead = latestMessageDict["_isRead"] as? Bool
                {
                    let dateString = date  + " " + time
                    guard let date = self.convertToDate(from: dateString) else {
                        print("Failed to convert date.")
                        return
                    }
                    
                    var kind : MessageKind?
                    if _type == "photo"
                    {
                        
                        guard let imgUrl =  URL(string: message),
                              let placeholder = UIImage(named: "error") else
                        {
                            return
                        }
                        
                        let size = self.createDynamicSize()
                        
                        let media = Media(url: imgUrl, image: nil, placeholderImage: placeholder, size: size)
                        
                        kind = .photo(media)
                    }
                    else
                    {
                        kind =  .text(message)
                    }
                    
                    guard let finalKind = kind else
                    {
                        return
                    }
                    
                    let sender = Sender(senderId: _senderEmail, displayName: self.friendName , photoURL: url)
                    
                    let message = Message(sender:sender , messageId: _messageid, sentDate: date, kind: finalKind)
                    
                    newMessage.append(message)
                    
                }
                
                self.messages.removeAll()
                self.messages.append(contentsOf: newMessage)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                
            }
            
        }
    }
    
    private func createDynamicSize() -> CGSize{
        // Use a dynamic width based on the screen width
        let screenWidth = UIScreen.main.bounds.width
        
        let width = screenWidth * 0.6 // 60% of screen width
        let height = width * 3 / 4    // Maintain a 4:3 aspect ratio
        let dynamicSize = CGSize(width: width, height: height)
        
        return dynamicSize
    }
    
    
    private  func convertToDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy hh:mm a" // Format for your date string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent parsing
        return dateFormatter.date(from: dateString)
    }
    
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

extension ChatViewController:PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        
        for result in results {
            
            //for image
            result.itemProvider.loadObject(ofClass: UIImage.self) { item,error in
                guard let image = item as? UIImage,error == nil else { return }
                
                
                
                let forlderName = "conversationImageFor\(self.otherUserEmail)"
                CloudinaryManager().uploadImage(image, folderName: forlderName) { url, error in
                    
                    if let error = error {
                        print("Image upload failed in Cloudinary: \(error.localizedDescription)")
                        return
                    }
                    guard let urlstring = url else {
                        print("Image URL not found")
                        return
                    }
                    
                    guard let selfSender = self.selfSender,
                          let messageID = self.createMessageID() else
                    {
                        return
                    }
                    
                    guard let url = URL(string:urlstring),let placeholder = UIImage(named: "error") else
                    {
                        return
                    }
                    
                    let media = Media(url: url,image: nil,placeholderImage: placeholder, size: .zero)
                    
                    let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .photo(media))
                    
                    // Create a  conversation in the database
                    FirebaseDatabaseManager.shared.createNewConversation(with: self.otherUserEmail,name: self.friendName,profileURL:self.otherUserPRofileUrl,firstMessage: message)
                    {
                        success in
                           if success
                           {
                               print("Message sent successfully")
                               self.listenForMessages()
                               
                           }
                           else
                           {
                               print("Message not sent!")
                           }
                       
                    }
                    
  
                }
            }
        }
    }
}























//    private func showOptionsMenu(for cell: MessageCollectionViewCell) {
//
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//
//        alert.addAction(UIAlertAction(title: "Translate", style: .default, handler: { _ in
//
//            guard let indexPath = self.messagesCollectionView.indexPath(for: cell) else {
//                print("index not found")
//                return
//            }
//            let selectedMessage = self.messages[indexPath.section]
//
//            // Translate the selected message
//            //self.translateMessage(message: selectedMessage)
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "Remove Message", style: .destructive, handler: { _ in
//
//            print("tapped reaction")
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        present(alert, animated: true, completion: nil)
//    }
    
//    private func  translateMessage(message: Message?)
//    {
//
//        guard let message = message else {return}
//
//        switch message.kind {
//        case .text(let text):
//            MyMemoryTranslationService.shared.translate(text: text ){ translatedText in
//
//                guard let translatedText = translatedText else {
//
//                    print("translation failed")
//                    return
//                }
//
//                if let index = self.messages.firstIndex(where: { $0.messageId == message.messageId })
//                {
//                    self.messages[index] = Message(sender: message.sender, messageId: message.messageId, sentDate: message.sentDate, kind: .text(translatedText))
//
//                    self.messagesCollectionView.reloadData()
//
//                }
//            }
//        default:
//            break
//        }
//    }
