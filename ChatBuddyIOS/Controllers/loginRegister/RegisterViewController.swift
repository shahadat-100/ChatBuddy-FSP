//
//  RegisterViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var fullNametxt: UITextField!
    @IBOutlet weak var UserNameTxt: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmpasswordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullNametxt.delegate = self
        UserNameTxt.delegate = self
        emailText.delegate = self
        passwordText.delegate = self
        confirmpasswordText.delegate = self
       // fullNametxt.becomeFirstResponder()
        
    }
    

    @IBAction func singUpbutton(_ sender: UIButton) {
        
        fullNametxt.resignFirstResponder()
        UserNameTxt.resignFirstResponder()
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        confirmpasswordText.resignFirstResponder()
        
        
        guard let fullname = fullNametxt.text, !fullname.isEmpty else
        {
            showAlert(title: "full name")
            return
        }
        guard let user = UserNameTxt.text , !user.isEmpty else {
            showAlert(title: "user")
            return
        }
        guard let email = emailText.text ,!email.isEmpty
        else{
            showAlert(title: "email")
            return
        }
        guard let password = passwordText.text , !password.isEmpty else
        {
            showAlert(title: "password")
            return
        }
        
        guard let confirmPass = confirmpasswordText.text, !confirmPass.isEmpty else
        {
            showAlert(title: "Confirm password")
            return
        }
        
        if !isValidEmail(email)
        {
            showAlert1(title: "Invalid email format." )
            return
        }
        if password.count < 8 && !isValidPassword(password)
        {
            showAlert1(title:  "Password must include uppercase, lowercase, number, and symbol.")
            return
        }
        if confirmPass.count < 8 && !isValidPassword(confirmPass)
        {
            showAlert1(title:  "Password must include uppercase, lowercase, number, and symbol.")
            return
        }

        
        if !isSamePass(pass: password, pass1: confirmPass)
        {
            showAlert1(title: "Password does not match!")
        }
        
        
        //navigate to login
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func alereadyhavAccBUtton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension RegisterViewController
{
    
    private func showAlert(title:String)
    {
        let alert = UIAlertController(title: "Woops!", message: "The \(title) field is empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okey", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func showAlert1(title:String)
    {
        let alert = UIAlertController(title:title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okey", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private  func isValidPassword(_ password: String) -> Bool{
      
        var hasUpperCase = false
        var hasLowerCase = false
        var hasNumber = false
        var hasSpecialCharecter = false
        
       
        for character in password {
            if character.isUppercase {
                hasUpperCase = true
            } else if character.isLowercase {
                hasLowerCase = true
            } else if character.isNumber {
                hasNumber = true
            } else if character.isSymbol || character.isPunctuation{
                hasSpecialCharecter = true
            }
        }
        
        return hasUpperCase && hasLowerCase && hasNumber && hasSpecialCharecter
    }
    
    private func isSamePass(pass:String,pass1:String)->Bool
    {
        return pass == pass1
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailPattern).evaluate(with: email)
    }

}


extension RegisterViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == fullNametxt
        {
            UserNameTxt.becomeFirstResponder()
        }
        else if textField == UserNameTxt
        {
            emailText.becomeFirstResponder()
        }else if textField == emailText
        {
            passwordText.becomeFirstResponder()
        }
        else if textField == passwordText
        {
            confirmpasswordText.becomeFirstResponder()
        }
        else if textField == confirmpasswordText
        {
            singUpbutton(UIButton().self)
 
        }
        
        return true
    }
}
