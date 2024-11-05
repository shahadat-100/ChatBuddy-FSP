//
//  RegisterViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmpasswordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstName.delegate = self
        lastName.delegate = self
        emailText.delegate = self
        passwordText.delegate = self
        confirmpasswordText.delegate = self
       // fullNametxt.becomeFirstResponder()
        
    }
    

    @IBAction func singUpbutton(_ sender: UIButton) {
        
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        confirmpasswordText.resignFirstResponder()
        
        
        guard let firstName = firstName.text, !firstName.isEmpty else
        {
            showAlert(title: "First name")
            return
        }
        
        guard let lastName = lastName.text , !lastName.isEmpty else {
            showAlert(title: "Last name")
            return
        }
        
        guard let email = emailText.text ,!email.isEmpty
        else{
            showAlert(title: "email")
            return
        }
        
        if !isValidEmail(email)
        {
            showAlert1(title: "Invalid email format." )
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
        
        if password.count >= 8 && !isValidPassword(password)
        {
            showAlert1(title:  "Password must include uppercase, lowercase, number, and symbol.")
            return
        }
        
        if !isValidPassword(confirmPass)
        {
            showAlert1(title:  "Password must include uppercase, lowercase, number, and symbol.")
            return
        }

        
        if !isSamePass(pass: password, pass1: confirmPass)
        {
            showAlert1(title: "Password does not match!")
            return
        }
        
        if password.count < 8
        {
            showAlert1(title: "Password must be at least 8 characters long.")
            return
        }
        // register by firebase
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: confirmPass) { authResult , error in
            
            guard let result = authResult, error == nil else
            {
                print("Got an error Creating user!")
                return
            }
            let user = result.user
            print("created user: \(user)")
        }
        
        
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
    
    // check is email valid or not!
    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailPattern).evaluate(with: email)
    }

}


extension RegisterViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstName
        {
            lastName.becomeFirstResponder()
        }
        else if textField == lastName
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
