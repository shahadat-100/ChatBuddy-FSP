//
//  photoAddViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 5/11/24.
//

import UIKit
import PhotosUI
import SDWebImage

class photoAddViewController: UIViewController {
    
    @IBOutlet weak var ProfileImg: UIImageView!
    @IBOutlet weak var viewforImg: UIView!
    @IBOutlet weak var imglbl: UILabel!
    @IBOutlet weak var buttonName: UIButton!
    @IBOutlet weak var butnlbl: UILabel!
    
   
    
    let cloudinaryManager = CloudinaryManager()
    
    
    var emailAddess:String?
    
    var flag : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flag = true
        ProfileImg.clipsToBounds = true
        addGesture()
        validateProfileImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        ProfileImg.clipsToBounds = true
        ProfileImg.layer.cornerRadius = ProfileImg.frame.width / 2
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        
        self.navigationController?.dismiss(animated: true)
    }
    
}


extension photoAddViewController
{
    
    
    private func validateProfileImage()
    {
        guard let emailAddess = emailAddess else {return}
        
        FirebaseDatabaseManager.shared.fetchUserProfileURL(with: emailAddess) { imageURl in
            
            if let imageURl = imageURl
            {
                self.imglbl.text = "Update Profile Picture"
                self.butnlbl.text = "Skip"
                self.flag = false
                
                if let imageUrl = URL(string: imageURl)
                {
                    // Load image asynchronously using SDWebImage
                    self.ProfileImg.sd_setImage(with: imageUrl){
                        image,error,types,url in
                        
                        if error != nil
                        {
                            print("error while loading image")
                            return
                        }
                        
                    }
                    
                }
            }
            
            
        }
    }
    
    
    private func addGesture()
    {
       
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(openGalery))
        ProfileImg.addGestureRecognizer(imgTap)
    }
    
    @objc func openGalery()
    {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        let pickerVc = PHPickerViewController(configuration: config)
        pickerVc.delegate = self
        present(pickerVc, animated: true)
    }
}

extension photoAddViewController:PHPickerViewControllerDelegate
{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
      
        if flag
        {
            flag = false
        }
        flag = true
        
        for result in results {
            
            //for image
            result.itemProvider.loadObject(ofClass: UIImage.self) { item,error in
                guard let image = item as? UIImage,error == nil  else { return }
               
                DispatchQueue.main.async {
                    if self.flag
                    {
                        self.butnlbl.text = "Update"
                    }
                    self.ProfileImg.image = image

                }
                
                guard let emailAddess = self.emailAddess else {return}
                
                self.cloudinaryManager.uploadImage(image,folderName: "userProfilePictures") {imageUrl, error in
                    if let error = error {
                        print("Image upload failed in Cloudinary: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let imageUrl = imageUrl else {
                        print("Image URL not found")
                        return
                    }
                    
                    FirebaseDatabaseManager().saveProfileURL(imageUrl: imageUrl, forUser: emailAddess)

                }
                
            }
            
        }
    }
    
}

/**/
