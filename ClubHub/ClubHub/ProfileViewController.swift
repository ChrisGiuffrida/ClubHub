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
    

    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var ClubsTextLabel: UILabel!
    @IBOutlet weak var UpcomingTextLabel: UILabel!
    @IBOutlet weak var UserDescriptionTextLabel: UILabel!
    
    @IBOutlet weak var ProfileSegmentControl: UISegmentedControl!
    @IBOutlet weak var ClubsView: UIView!
    @IBOutlet weak var FriendsView: UIView!
    @IBOutlet weak var ProfileButton: UIButton!
    
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _clubHandle: DatabaseHandle!
    fileprivate var _friendHandle: DatabaseHandle!
    var clubs: [(ClubKey: String, ClubName: String)]! = []
    
    var ClubViewController: UITableViewController!
    var FriendsViewController: UITableViewController!
    
    var user_description: String = ""
    var UserID: String =  Auth.auth().currentUser!.uid
    var isFollowing: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        ProfileButton.isHidden = true
        if UserID == Auth.auth().currentUser!.uid {
            var settings = UIImage(named: "Settings")
            settings = settings?.withRenderingMode(.alwaysTemplate)
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: settings, style: .plain, target: self, action: #selector(adjustSettings))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            ProfileButton.setTitle("Edit Profile", for: .normal)
            ProfileButton.isHidden = false
        }
        else {
            ref.child("users").child(UserID).child("followers").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
                if snapshot.value is NSNull {
                    self.ProfileButton.setTitle("Follow", for: .normal)
                    self.ProfileButton.isHidden = false
                }
                else {
                    self.ProfileButton.setTitle("Unfollow", for: .normal)
                    self.ProfileButton.isHidden = false
                    self.isFollowing = true
                }
            })
        }
        
        ref.child("users").child(UserID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let grad_year = value?["grad_year"] as? String ?? "GradYear"
            let major = value?["major"] as? String ?? "Major"
            let college = value?["college"] as? String ?? "College"
            let university = "University of Notre Dame"
            let firstName = value?["firstName"] as? String
            let lastName = value?["lastName"] as? String
            self.navigationItem.title = firstName! + " " + lastName!
            self.UserDescriptionTextLabel.text = "Class of " + grad_year + "\n" + major + "\n" + college + "\n" + university
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        let pictureRef = storageRef.child("user_photos/" + UserID)
        // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
        pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
            } else {
                self.ProfilePicture.image = UIImage(data: data!)
            }
        }
        
        ref.child("users").child(UserID).child("clubs").observe(.value, with:{ (snapshot: DataSnapshot) in
            self.ClubsTextLabel.text = String(Int(snapshot.childrenCount))
        })
        
        
        ref.child("users").child(UserID).child("events").observe(.value, with:{ (snapshot: DataSnapshot) in
            self.UpcomingTextLabel.text = String(Int(snapshot.childrenCount))
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClubViewController = self.childViewControllers[0] as! ClubTableViewController
        FriendsViewController = self.childViewControllers[1] as! FriendTableViewController

        configureAuth()
        configureDatabase()
        configureStorage()
        
        ProfilePicture.layer.borderWidth = 1
        ProfilePicture.layer.masksToBounds = false
        ProfilePicture.layer.cornerRadius = ProfilePicture.frame.height/2
        ProfilePicture.clipsToBounds = true
        ProfilePicture.contentMode = .scaleAspectFill;
        
        ClubsView.isHidden = false
        FriendsView.isHidden = true
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
                    self.UserID = (self.user?.uid)!
                }
            } else {
                // user must sign in
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // get a reference to the second view controller
        if segue.identifier == "editProfile" {
            let secondViewController = segue.destination as! CompleteSignupViewController
            secondViewController.isEditing = true
        }
        
        if segue.identifier == "clubTableSegue" {
            print("club: " + UserID)
            let secondViewController = segue.destination as! ClubTableViewController
            secondViewController.UserID = self.UserID
        }
        
        if segue.identifier == "followingTableSegue" {
            print("following: " + UserID)
            let secondViewController = segue.destination as! FriendTableViewController
            secondViewController.UserID = self.UserID
        }
    }
    
    @IBAction func doProfileButtonAction(_ sender: Any) {
        if UserID == Auth.auth().currentUser!.uid {
            performSegue(withIdentifier: "editProfile", sender: self)
        }
        else if isFollowing {
            ref.child("users").child(Auth.auth().currentUser!.uid).child("following").child(UserID).removeValue()
            ref.child("users").child(UserID).child("followers").child(Auth.auth().currentUser!.uid).removeValue()
            
            ProfileButton.setTitle("Follow", for: .normal)
            isFollowing = false
        }
        else {
            let user: [AnyHashable: Any] = [UserID: true]
            ref.child("users").child(Auth.auth().currentUser!.uid).child("following").updateChildValues(user)
            
            let myself: [AnyHashable: Any] = [(Auth.auth().currentUser!.uid): true]
            ref.child("users").child(UserID).child("followers").updateChildValues(myself)
            
            ProfileButton.setTitle("Unfollow", for: .normal)
            isFollowing = true
        }
    }
    
    @objc func adjustSettings() {
        let alertVC = UIAlertController(title: "Sign Out?", message: "Would you like to sign out of your account?", preferredStyle: .alert)
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let alertActionOkay = UIAlertAction(title: "Continue", style: .default) {
            (_) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            self.performSegue(withIdentifier: "loggingOut", sender: self)
        }
        alertVC.addAction(alertActionCancel)
        alertVC.addAction(alertActionOkay)
        self.present(alertVC, animated: true) {}
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch ProfileSegmentControl.selectedSegmentIndex {
            case 0:
                ClubsView.isHidden = false
                FriendsView.isHidden = true
                break
            case 1:
                ClubsView.isHidden = true
                FriendsView.isHidden = false
                break
            case 2:
                ClubsView.isHidden = true
                FriendsView.isHidden = true
                break
            default:
                break
        }
    }
}
