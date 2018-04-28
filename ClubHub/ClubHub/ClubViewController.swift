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
    var ClubEventKey: String = ""
    var ClubName: String = ""
    var ClubEventName: String = ""
    var CameFromCamera: Bool = false
    
    
    override func viewDidAppear(_ animated: Bool) {
        if(CameFromCamera == true) {
            let alertPrompt = UIAlertController(title: "Open App", message: "Do you want to sign into \(ClubName)'s \(ClubEventName) event?", preferredStyle: .actionSheet)
            let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                
                let members: [AnyHashable: Any] = [(self.user?.uid)!: true]
                let events: [AnyHashable: Any] = [self.ClubKey + "|" + self.ClubEventKey: true]
            self.ref.child("clubs").child(self.ClubKey).child("events").child(self.ClubEventKey).child("members").updateChildValues(members)
                self.ref.child("users").child((self.user?.uid)!).child("events").updateChildValues(events)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                //_ = self.navigationController?.popViewController(animated: true)
                let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController")
                self.present(cameraViewController!, animated: true)
            })
                
            alertPrompt.addAction(confirmAction)
            alertPrompt.addAction(cancelAction)
            
            present(alertPrompt, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        configureAuth()
        configureDatabase()

        ref.child("clubs").child(ClubKey).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.ClubName = value?["club_name"] as? String ?? "ClubName"
            self.ClubNameLabel.text = value?["club_name"] as? String ?? "ClubName"
        }) { (error) in
            print(error.localizedDescription)
        }

        if CameFromCamera {
            ref.child("clubs").child(ClubKey).child("events").child(ClubEventKey).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                self.ClubEventName = value?["event_name"] as? String ?? "EventName"
            }) { (error) in
                print(error.localizedDescription)
            }
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
        //performSegue(withIdentifier: "addClubEvent", sender: self)
    }
}

