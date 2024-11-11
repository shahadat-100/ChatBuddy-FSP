//
//  CloudinaryManager.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 10/11/24.
//

import Foundation
import Cloudinary
import UIKit

class CloudinaryManager {
    
    private let cloudinary: CLDCloudinary

    init() {
        let config = CLDConfiguration(cloudName: "doz0lpkep", apiKey: "789777974481292", apiSecret: "uWBtVO4lT9UQn6hh7pUEfaban_E")
        cloudinary = CLDCloudinary(configuration: config)
    }

    func uploadImage(_ image: UIImage, completion: @escaping (String?, Error?) -> Void) {
       
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            completion(nil, NSError())
            return
        }

        let params = CLDUploadRequestParams()
        params.setFolder("userProfilePictures")

        
        cloudinary.createUploader().upload(data: imageData, uploadPreset: "chatBuddy-preset", params: params)
            .response { result, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    // If the upload succeeds, return the image and the URL
                    if let imgUrl = result?.secureUrl {
                        completion(imgUrl, nil)
                        print("iamge successfully saved in cloudinary ")
                    } else {
                        completion(nil, NSError())
                    }
                }
            }
    }

}



