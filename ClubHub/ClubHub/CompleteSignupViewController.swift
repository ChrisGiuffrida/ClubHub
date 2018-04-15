//
//  CompleteSignupViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class CompleteSignupViewController: UIViewController {
    
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var FinishSignUpButton: UIButton!
    
    var ref: DatabaseReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        FinishSignUpButton.isEnabled = false
        
        FirstNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        LastNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func editingChanged() {
        guard
            let firstName = FirstNameTextField.text, !firstName.isEmpty,
            let lastName = LastNameTextField.text, !lastName.isEmpty
        else {
            self.FinishSignUpButton.isEnabled = false
            return
        }
        FinishSignUpButton.isEnabled = true
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func configureAuth() {
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            // check if there is a current user
            if let activeUser = user {
                // check if the current app user is the current FIRUser
                if self.user != activeUser {
                    self.user = activeUser
                }
            } else {
                // user must sign in

            }
        }
    }
    
    @IBAction func finishSignUp(_ sender: Any) {
        if user != nil {
            self.ref.child("users").child((user?.uid)!).setValue(["firstName": FirstNameTextField.text, "lastName": LastNameTextField.text, "email": user?.email])
            performSegue(withIdentifier: "finishedSigningUp", sender: self)
        }
        else {
            
        }
    }
    
}

