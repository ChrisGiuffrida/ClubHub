//
//  CreateNewClubViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class CreateNewClubViewController: UIViewController {
    

    @IBOutlet weak var ClubNameTextField: UITextField!
    @IBOutlet weak var CreateClubButton: UIButton!
    
    var ref: DatabaseReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var ClubKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        //FinishSignUpButton.isEnabled = false
        
        //FirstNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        //LastNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @objc func editingChanged() {
//        guard
//            let firstName = FirstNameTextField.text, !firstName.isEmpty,
//            let lastName = LastNameTextField.text, !lastName.isEmpty
//            else {
//                self.FinishSignUpButton.isEnabled = false
//                return
//        }
//        FinishSignUpButton.isEnabled = true
//    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let secondViewController = segue.destination as! ClubViewController
        
        // set a variable in the second view controller with the String to pass
        secondViewController.ClubKey = ClubKey
    }
    
    @IBAction func createClub(_ sender: Any) {
        if user != nil {
            ClubKey = ref.child("clubs").childByAutoId().key
            self.ref.child("clubs").child(ClubKey).setValue(["club_name": ClubNameTextField.text])
            performSegue(withIdentifier: "goToNewClub", sender: self)
        }
    }
}

