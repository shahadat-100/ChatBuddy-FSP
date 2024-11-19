import Foundation

// Model for the latest message in a conversation
class LattesMessage {
    let time : String
    let date: String
    let text: String
    let is_read: Bool
   
    init(time: String, date: String, text: String, is_read: Bool) {
        self.time = time
        self.date = date
        self.text = text
        self.is_read = is_read
    }
}

// Model for a single conversation, holding the latest message
class Conversation {
    let id: String
    let senderEmail:String
    let type :String
    let latestMessage: LattesMessage
    
    init(id: String, senderEmail: String, type: String, latestMessage: LattesMessage) {
        self.id = id
        self.senderEmail = senderEmail
        self.type = type
        self.latestMessage = latestMessage
    }
}

// Model for a conversation list with friend details and multiple conversations
class ConversationList {
    let name: String
    let UserEmail: String
    let profileUrl: String
    let conversation: [Conversation] // A list of conversations (could be one or more)
    
    
    init(name: String, otherUserEmail: String, profileUrl: String, conversation: [Conversation]) {
        self.name = name
        self.UserEmail = otherUserEmail
        self.profileUrl = profileUrl
        self.conversation = conversation
    }
}

