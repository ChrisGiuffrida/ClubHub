//
//  ClubViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class ClubViewController: UIViewController {
    
    @IBOutlet weak var ClubNameLabel: UILabel!
    @IBOutlet weak var AddEventButton: UIButton!
    var ref: DatabaseReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var ClubKey: String = ""
    var ClubName: String = "Test"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        
        ref.child("clubs").child(ClubKey).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.ClubNameLabel.text = value?["club_name"] as? String ?? "ClubName"
        }) { (error) in
            print(error.localizedDescription)
        }
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let secondViewController = segue.destination as! CreateClubEventViewController
        
        // set a variable in the second view controller with the String to pass
        secondViewController.ClubKey = ClubKey
    }
    
    @IBAction func createNewEvent(_ sender: Any) {
        performSegue(withIdentifier: "addClubEvent", sender: self)
    }
}

