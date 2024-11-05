//
//  LoginViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var UserNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserNameTxt.delegate = self
        emailTxt.delegate = self
        passwordTxt.delegate = self
        
      
    
        
        
        
       
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
       
        UserNameTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        
        
        guard let user = UserNameTxt.text , !user.isEmpty else {
            showAlert(title: "user")
            return
        }
        guard let email = emailTxt.text ,!email.isEmpty
        else{
            showAlert(title: "email")
            return
        }
        guard let password = passwordTxt.text , !password.isEmpty else
        {
            showAlert(title: "password")
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
        
        //firebase code
        
        
    }
    
    @IBAction func singUpButton(_ sender: UIButton) {
        
        guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
}

extension LoginViewController
{
    private func showAlert(title:String)
    {
        let alert = UIAlertController(title: "Woops!", message: "The \(title) field is empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okey", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func showAlert1(title:String)
    {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okey", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailPattern).evaluate(with: email)
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
    

}


extension LoginViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == UserNameTxt
        {
            emailTxt.becomeFirstResponder()
        }else if textField == emailTxt
        {
            passwordTxt.becomeFirstResponder()
        }
        else if textField == passwordTxt
        {
            loginButton(UIButton().self)
        }
        
        return true
    }
}
