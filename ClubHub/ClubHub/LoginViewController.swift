//
//  LoginViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInUIDelegate,  FBSDKLoginButtonDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var GIDSignInButton: GIDSignInButton!
    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    @IBOutlet weak var StandardLogInButton: UIButton!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var CreateAccountButton: UIButton!
    @IBOutlet weak var ForgotPasswordButton: UIButton!
    
    
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let buttonText = NSAttributedString(string: "Sign In")
        FBLoginButton.setAttributedTitle(buttonText, for: .normal)
        FBLoginButton.delegate = self
        FBSDKLoginManager().logOut()
        
        configureDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if result.isCancelled {
            return
        }
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // ...
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (data, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
            
            if(data?.additionalUserInfo?.isNewUser == true) {
                self.performSegue(withIdentifier: "finishAccount", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "goingHome", sender: self)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("You have logged out!")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        Auth.auth().signInAndRetrieveData(with: credential) { (data, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
            
            if(data?.additionalUserInfo?.isNewUser == true) {
                self.performSegue(withIdentifier: "finishAccount", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "goingHome", sender: self)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    @IBAction func standardLogIn(_ sender: Any) {
        let email: String! = self.UsernameTextField.text
        let password: String! = self.PasswordTextField.text
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch(errCode) {
                    case .invalidEmail:
                        self.UsernameTextField.text = ""
                    default:
                        self.UsernameTextField.text = self.UsernameTextField.text
                    }
                    self.PasswordTextField.text = ""
                    
                    let alertController = UIAlertController(title: "Log In Attempt Failed", message: error?.localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                        
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                        
                    }
                }
            }
            else {
                if !(user?.isEmailVerified)!{
                    let alertVC = UIAlertController(title: "Email Not Verified", message: "Your email address has not yet been verified. Do you want us to send another verification email to \(self.UsernameTextField.text).", preferredStyle: .alert)
                    let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                        (_) in
                        user?.sendEmailVerification(completion: nil)
                    }
                    alertVC.addAction(alertActionOkay)
                    alertVC.addAction(alertActionCancel)
                    do {
                        try Auth.auth().signOut()
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                    self.present(alertVC, animated: true, completion: nil)
                } else {
                    print ("Email verified. Signing in...")
                }
                self.performSegue(withIdentifier: "goingHome", sender: self)
            }
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        let email: String! = self.UsernameTextField.text
        let password: String! = self.PasswordTextField.text
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            print(error?.localizedDescription)
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch(errCode) {
                        case .invalidEmail:
                            self.UsernameTextField.text = ""
                        default:
                            self.UsernameTextField.text = self.UsernameTextField.text
                    }
                    self.PasswordTextField.text = ""
                
                    let alertController = UIAlertController(title: "Sign Up Failed", message: error?.localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {}
                }
            }
            else {
                user?.sendEmailVerification(completion: nil)
                self.performSegue(withIdentifier: "finishAccount", sender: self)
            }
        }
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let alertVC = UIAlertController(title: "Password Reset", message: "Would you like us to send a password reset link to \(self.UsernameTextField.text)?", preferredStyle: .alert)
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let alertActionOkay = UIAlertAction(title: "Send", style: .default) {
            (_) in
            Auth.auth().sendPasswordReset(withEmail: self.UsernameTextField.text!, completion: nil)
        }
        alertVC.addAction(alertActionCancel)
        alertVC.addAction(alertActionOkay)
        self.present(alertVC, animated: true) {}
    }
}

