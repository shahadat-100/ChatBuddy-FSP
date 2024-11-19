//
//  TranslatorManager.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 18/11/24.
//

//import Foundation
//import Alamofire
//
//// Define a struct to map the JSON response
//struct TranslationResponse: Decodable {
//    let responseData: ResponseData
//}
//
//struct ResponseData: Decodable {
//    let translatedText: String
//}
//
//class MyMemoryTranslationService {
//    static let shared = MyMemoryTranslationService()
//    
//    private let apiURL = "https://api.mymemory.translated.net/get"
//    
//    // Function to translate text
//    func translate(text: String, completion: @escaping (String?) -> Void) {
//        // Determine source and target language based on input text
//        let sourceLanguage: String
//        let targetLanguage: String
//        
//        // Simple check if the text is in Bangla or English (basic check)
//        if isBangla(text) {
//            sourceLanguage = "bn"
//            targetLanguage = "en"
//        } else if isEnglish(text) {
//            sourceLanguage = "en"
//            targetLanguage = "bn"
//        } else {
//            // If text is neither Bangla nor English, return nil with a message
//            print("Translation not supported for this language.")
//            completion(nil)
//            return
//        }
//        
//        // Prepare parameters for the translation request
//        let parameters: [String: Any] = [
//            "q": text,
//            "langpair": "\(sourceLanguage)|\(targetLanguage)"
//        ]
//        
//        // Make the API request using Alamofire with responseDecodable
//        AF.request(apiURL, method: .get, parameters: parameters)
//            .responseDecodable(of: TranslationResponse.self) { response in
//                guard let decodedResponse = response.value else {
//                    completion(nil)
//                    return
//                }
//                
//                let translatedText = decodedResponse.responseData.translatedText
//                completion(translatedText)
//            }
//
//    }
//    
//    // Simple function to check if text contains Bangla characters (basic check)
//    private func isBangla(_ text: String) -> Bool {
//        let banglaRange = text.range(of: "[\\u0980-\\u09FF]", options: .regularExpression)
//        return banglaRange != nil
//    }
//    
//    // Simple function to check if text contains English characters (basic check)
//    private func isEnglish(_ text: String) -> Bool {
//        let englishRange = text.range(of: "[a-zA-Z]", options: .regularExpression)
//        return englishRange != nil
//    }
//}
