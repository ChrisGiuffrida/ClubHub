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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        let buttonText = NSAttributedString(string: "Sign In")
        FBLoginButton.setAttributedTitle(buttonText, for: .normal)
        FBLoginButton.delegate = self
        FBSDKLoginManager().logOut()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                print(error.localizedDescription)
                return
            }
            // User is signed in
            // ...
            self.performSegue(withIdentifier: "goingHome", sender: self)
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
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
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
            if let error = error {
                self.UsernameTextField.text = ""
                self.PasswordTextField.text = ""
                
                let alertController = UIAlertController(title: "Login Attempt Failed", message: error.localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true) {
                    
                }
            }
            else {
                self.performSegue(withIdentifier: "goingHome", sender: self)
            }
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        let email: String! = self.UsernameTextField.text
        let password: String! = self.PasswordTextField.text
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch(errCode) {
                        case .invalidEmail:
                            self.UsernameTextField.text = ""
                        default:
                            self.UsernameTextField.text = self.UsernameTextField.text
                    }
                    self.PasswordTextField.text = ""
                
                    let alertController = UIAlertController(title: "Sign up Failed", message: error?.localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                        
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                        
                    }
                }
            }
            else {
//                self.performSegue(withIdentifier: "goingHome", sender: self)
            }
        }
    }
}

