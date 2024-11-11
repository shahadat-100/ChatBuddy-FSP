//
//  RegisterViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var UserNameTxt: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmpasswordText: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstName.delegate = self
        lastName.delegate = self
        UserNameTxt.delegate = self
        emailText.delegate = self
        passwordText.delegate = self
        confirmpasswordText.delegate = self
        // fullNametxt.becomeFirstResponder()
        
    }
    
    
    @IBAction func singUpbutton(_ sender: UIButton) {
        
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        UserNameTxt.resignFirstResponder()
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        confirmpasswordText.resignFirstResponder()
        
        
        guard let firstName = firstName.text, !firstName.isEmpty else
        {
            showErrorAlert(title: "First name")
            return
        }
        
        guard let lastName = lastName.text , !lastName.isEmpty else {
            showErrorAlert(title: "Last name")
            return
        }
        
        guard let userName = UserNameTxt.text , !userName.isEmpty else {
            showErrorAlert(title: "user")
            return
        }
        
        guard let email = emailText.text ,!email.isEmpty
        else{
            showErrorAlert(title: "email")
            return
        }
        
        if !isValidEmail(email)
        {
            showLoginErrorAlert(title: "Invalid email format." )
            return
        }
        
        guard let password = passwordText.text , !password.isEmpty else
        {
            showErrorAlert(title: "password")
            return
        }
        
        guard let confirmPass = confirmpasswordText.text, !confirmPass.isEmpty else
        {
            showErrorAlert(title: "Confirm password")
            return
        }
        
        if password.count >= 8 && !isValidPassword(password)
        {
            showLoginErrorAlert(title:  "Password must include uppercase, lowercase, number, and symbol.")
            return
        }
        
        if !isValidPassword(confirmPass)
        {
            showLoginErrorAlert(title:  "Password must include uppercase, lowercase, number, and symbol.")
            return
        }
        
        
        if !isSamePass(pass: password, pass1: confirmPass)
        {
            showLoginErrorAlert(title: "Password does not match!")
            return
        }
        
        if password.count < 8
        {
            showLoginErrorAlert(title: "Password must be at least 8 characters long.")
            return
        }
    
        spinner.detailTextLabel.text = "Registering..."
        spinner.show(in: view, animated: true)
        // register by firebase
        
        
        
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: confirmPass) { [weak self] authResult , error in
            
            
            if let maybeError = error as NSError? { // if there was an error, handle it
                if let authErrorCode = AuthErrorCode.init(rawValue: maybeError.code) {
                    if authErrorCode == .emailAlreadyInUse {
                        self?.showLoginErrorAlert(title: "email is already in use.")
                    } else {
                        self?.showLoginErrorAlert(title: "Login Failed: An error occurred. Please try again later.")
                    }
                }
            }
            
            guard let result = authResult else
            {
                print("Got an error Creating user!")
                return
            }
            let user = result.user
            print("created user: \(user)")
            
            FirebaseDatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, userName: userName, emailAddress: email))
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                print("User signed out after registration")
                
                DispatchQueue.main.async {
                    self?.spinner.dismiss(animated: true)
                }
                // go back login view
                self?.navigationController?.popViewController(animated: true)
            } catch let signOutError {
                print("Error signing out: ", signOutError)
            }
        }
        
    }
    
    @IBAction func alereadyhavAccBUtton(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension RegisterViewController
{
    
    private func showErrorAlert(title:String)
    {
        let alert = UIAlertController(title: "Woops!", message: "The \(title) field is empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okey", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func             showLoginErrorAlert(title:String)
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
    
    // check is email valid or not! // From ChatGPT
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
            UserNameTxt.becomeFirstResponder()
            
        }
        else if textField == UserNameTxt
        {
            emailText.becomeFirstResponder()
            
        }
        else if textField == emailText
        {
            passwordText.becomeFirstResponder()
        }
        else if textField == passwordText
        {
            confirmpasswordText.becomeFirstResponder()
        }
        else if textField == confirmpasswordText
        {
            confirmpasswordText.resignFirstResponder()
            
        }
        return true
    }
}
