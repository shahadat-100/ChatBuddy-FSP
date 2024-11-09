//
//  LoginViewController.swift
//  ChatBuddyIOS
//
//  Created by shahadat on 4/11/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import JGProgressHUD
class LoginViewController: UIViewController {
    
    
    
    @IBOutlet weak var googoleSingin: UIButton!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    private let spiner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxt.delegate = self
        passwordTxt.delegate = self
        
   
        
        
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        emailTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        
        guard let email = emailTxt.text ,!email.isEmpty
        else{
            showErrorAlert(title: "email")
            return
        }
        guard let password = passwordTxt.text , !password.isEmpty else
        {
            showErrorAlert(title: "password")
            return
        }
        if !isValidEmail(email)
        {
            showLoginErrorAlert(title: "Invalid email format." )
            return
        }
        if !isValidPassword(password)
        {
            showLoginErrorAlert(title:  "Password must include uppercase, lowercase, number, and symbol.")
            return
        }
        if password.count < 8
        {
            showLoginErrorAlert(title: "Password must be at least 8 characters long.")
            return
        }
        
        spiner.detailTextLabel.text = "Logging in..."
        spiner.show(in: view, animated: true)
        
        // sing in account in firebase
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            
            
            
            // if there was an error, handle it
            guard error == nil else
            {
                self?.showLoginErrorAlert(title: "Login Failed: An error occurred. Please try again.")
                return
            }
            
            // Ensure authDataResult is not nil
            guard let result = authDataResult else {
                self?.showLoginErrorAlert(title: "An unexpected error occurred. Please try again.")
                return
            }
            
            // User signed in successfully
            let user = result.user
            print("Logged in successfully with \(user.email ?? "")")
            
            
            DispatchQueue.main.async {
                self?.spiner.dismiss(animated: true)
            }
            
            // Navigate to photoAddViewController
            guard let vc = self?.storyboard?.instantiateViewController(withIdentifier: "photoAddViewController") as? photoAddViewController else {return}
            vc.emailAddess = email
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        
    }
    
    @IBAction func singUpButton(_ sender: UIButton) {
        
        guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func googleSinginBuuton(_ sender: UIButton) {
        
        spiner.detailTextLabel.text = "Logging in..."
        spiner.show(in: view, animated: true)

        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let maybeError = error as NSError? { // if there was an error, handle it
                if let authErrorCode = AuthErrorCode.init(rawValue: maybeError.code) {
                    if authErrorCode == .emailAlreadyInUse {
                        self?.showLoginErrorAlert(title: "Email is already in use.")
                    } else {
                        self?.showLoginErrorAlert(title: "Login Failed: An error occurred. Please try again later.")
                    }
                }
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // ...
                print("user not logged in")
                return
            }
            
           
            guard let email = user.profile?.email,let firstName  = user.profile?.givenName,let lastName = user.profile?.familyName,let userName = user.profile?.name else {return}
            
            FirebaseDatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, userName: userName, emailAddress: email))
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            // ...
            
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { AuthDataResult, error in
                
                guard AuthDataResult != nil, error == nil else {
                    print("successfully logged in with Google credential")
                    return
                }
                
                print("successfully logged in with Google credential")
                
                
                
                DispatchQueue.main.async {
                    self?.spiner.dismiss(animated: true)
                }

                // Navigate to photoAddViewController
                guard let vc = self?.storyboard?.instantiateViewController(withIdentifier: "photoAddViewController") as? photoAddViewController else {return}
                vc.emailAddess = email
                self?.navigationController?.pushViewController(vc, animated: true)

                
            }
            
        }
        
    }
    
    
}

extension LoginViewController
{
    private func showErrorAlert(title:String)
    {
        let alert = UIAlertController(title: "Opps!", message: "The \(title) field is empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okey", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func showLoginErrorAlert(title:String)
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
        
         if textField == emailTxt
        {
            passwordTxt.becomeFirstResponder()
        }
        else if textField == passwordTxt
        {
            passwordTxt.resignFirstResponder()
        }
        
        return true
    }
}


//            if let maybeError = error as NSError? { // if there was an error, handle it
//                if let authErrorCode = AuthErrorCode.init(rawValue: maybeError.code) {
//                    if authErrorCode == .userNotFound {
//                        self.showLoginErrorAlert(title: "No Account Found: This email is not registered. Please sign up first.")
//                    } else if authErrorCode == .wrongPassword {
//                        self.showLoginErrorAlert(title: "Incorrect Password: Please check your password and try again.")
//                    } else {
//                        self.showLoginErrorAlert(title: "Login Failed: An error occurred. Please try again later.")
//                    }
//                }
//            }
