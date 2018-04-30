//
//  ProfileViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import QRCode

class ProfileViewController: UIViewController {
    

    @IBOutlet weak var SignOutButton: UIButton!
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var ClubsTextLabel: UILabel!
    @IBOutlet weak var AttendingClubLabel: UILabel!
    @IBOutlet weak var UpcomingTextLabel: UILabel!
    @IBOutlet weak var UserDescriptionTextLabel: UILabel!
    
    @IBOutlet weak var ProfileSegmentControl: UISegmentedControl!
    @IBOutlet weak var ClubsView: UIView!
    @IBOutlet weak var FriendsView: UIView!
    @IBOutlet weak var ActivityView: UIView!
    
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _clubHandle: DatabaseHandle!
    fileprivate var _friendHandle: DatabaseHandle!
    var clubs: [(ClubKey: String, ClubName: String)]! = []
    
    var ClubViewController: UITableViewController!
    var FriendsViewController: UITableViewController!
    var ActivityViewController: UITableViewController!
    
    var user_description: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClubViewController = self.childViewControllers[0] as! ClubTableViewController
        FriendsViewController = self.childViewControllers[1] as! FriendTableViewController
        ActivityViewController = self.childViewControllers[2] as! ActivityTableViewController

        configureAuth()
        configureDatabase()
        configureStorage()
        
        ProfilePicture.layer.borderWidth = 1
        ProfilePicture.layer.masksToBounds = false
        ProfilePicture.layer.cornerRadius = ProfilePicture.frame.height/2
        ProfilePicture.clipsToBounds = true
        ProfilePicture.contentMode = .scaleAspectFill;
        
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let grad_year = value?["grad_year"] as? String ?? "GradYear"
            let major = value?["major"] as? String ?? "Major"
            let college = value?["college"] as? String ?? "College"
            let university = "University of Notre Dame"

            self.UserDescriptionTextLabel.text = "Class of " + grad_year + "\n" + major + "\n" + college + "\n" + university

        }) { (error) in
            print(error.localizedDescription)
        }

        let pictureRef = storageRef.child("user_photos/" + Auth.auth().currentUser!.uid)
        // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
        pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
            } else {
                self.ProfilePicture.image = UIImage(data: data!)
            }
        }
        
        ClubsView.isHidden = false
        FriendsView.isHidden = true
        ActivityView.isHidden = true
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func configureStorage() {
        storageRef = Storage.storage().reference()
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
    
    @IBAction func indexChanged(_ sender: Any) {
        switch ProfileSegmentControl.selectedSegmentIndex {
            case 0:
                ClubsView.isHidden = false
                FriendsView.isHidden = true
                ActivityView.isHidden = true
                break
            case 1:
                ClubsView.isHidden = true
                FriendsView.isHidden = false
                ActivityView.isHidden = true
                break
            case 2:
                ClubsView.isHidden = true
                FriendsView.isHidden = true
                ActivityView.isHidden = false
                break
            default:
                break
        }
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        //performSegue(withIdentifier: "LogOut", sender: sender)
    }
}
