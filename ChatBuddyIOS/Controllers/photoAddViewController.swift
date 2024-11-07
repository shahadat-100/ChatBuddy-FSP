//
//  photoAddViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 5/11/24.
//

import UIKit
import PhotosUI

class photoAddViewController: UIViewController {

    @IBOutlet weak var ProfileImg: UIImageView!
    @IBOutlet weak var viewforImg: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileImg.translatesAutoresizingMaskIntoConstraints = false
        ProfileImg.clipsToBounds = true
        addGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ProfileImg.layer.cornerRadius = ProfileImg.frame.width / 2
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        
        self.navigationController?.dismiss(animated: true)
    }
    
}


extension photoAddViewController
{
    
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
        
        for result in results {
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { item,error in
                
                guard let image = item as? UIImage else {return}
                DispatchQueue.main.async {
                    self.ProfileImg.image = image
                }
            }
        }
    }
    
    
}



/**/
