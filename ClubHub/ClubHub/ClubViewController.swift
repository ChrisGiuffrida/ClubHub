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
    
    
    @IBOutlet weak var ClubPicture: UIImageView!
    @IBOutlet weak var ClubMemberLabel: UILabel!
    @IBOutlet weak var UpcomingEventLabel: UILabel!
    @IBOutlet weak var PastEventLabel: UILabel!
    @IBOutlet weak var ClubDescriptionLabel: UILabel!
    @IBOutlet weak var ClubButton: UIButton!
    
    @IBOutlet weak var AnalyticsButton: UIButton!
    var image: UIImage!
    
    
    @IBOutlet weak var ClubSegmentControl: UISegmentedControl!
    @IBOutlet weak var ClubMemberView: UIView!
    @IBOutlet weak var ClubEventView: UIView!
    
    var ClubKey: String = ""
    var ClubEventKey: String = ""
    var ClubName: String = ""
    var ClubEventName: String = ""
    var CameFromCamera: Bool = false
    var CameFromCreation: Bool = false
    var isAdmin: Bool = false
    var isMember: Bool = false
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _clubPictureHandle: DatabaseHandle!

    var MembersViewController: UITableViewController!
    var EventsViewController: UITableViewController!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        if CameFromCreation {
            ClubPicture.image = image
        }
        
        AnalyticsButton.isHidden = true
        ClubButton.isHidden = true
        ref.child("users").child(Auth.auth().currentUser!.uid).child("admin_clubs").observeSingleEvent(of: .value, with: {(snapshot) in
                for child in snapshot.children {
                    let child = child as? DataSnapshot
                    if let key = child?.key {
                        if key == self.ClubKey {
                            self.ClubButton.isHidden = false
                            self.ClubButton.setTitle("Edit Club", for: .normal)
                            self.isAdmin = true
                            self.AnalyticsButton.isHidden = false
                            
                            var plus = UIImage(named: "Plus")
                            plus = plus?.withRenderingMode(.alwaysTemplate)
                            
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: plus, style: .plain, target: self, action: #selector(self.addEvent))
                            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                        }
                    }
                }
                if !self.isAdmin {
                    self.ref.child("users").child(Auth.auth().currentUser!.uid).child("clubs").observeSingleEvent(of: .value, with: {(snapshot) in
                        for child in snapshot.children {
                            let child = child as? DataSnapshot
                            if let key = child?.key {
                                if key == self.ClubKey {
                                    self.ClubButton.isHidden = false
                                    self.ClubButton.setTitle("Leave Club", for: .normal)
                                    self.isMember = true
                                }
                            }
                        }
                        if !self.isMember{
                            self.ClubButton.setTitle("Join Club", for: .normal)
                            self.ClubButton.isHidden = false
                        }
                    })
                }
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAuth()
        configureDatabase()
        configureStorage()
        
        MembersViewController = self.childViewControllers[0] as! MembersTableViewController
        //EventsViewController = self.childViewControllers[1] as! EventsTableViewController

        
        let pictureRef = storageRef.child("club_photos/" + ClubKey)
        // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
        pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
            } else {
                // Data for "images/island.jpg" is returned
                self.ClubPicture.image = UIImage(data: data!)
            }
        }
    
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        ClubPicture.layer.borderWidth = 1
        ClubPicture.layer.masksToBounds = false
        ClubPicture.layer.cornerRadius = ClubPicture.frame.height/2
        ClubPicture.clipsToBounds = true
        ClubPicture.contentMode = .scaleAspectFill;

        ref.child("clubs").child(ClubKey).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let clubName = value?["club_name"] as? String ?? "ClubName"
            let clubDescriptionLabel = value?["club_description"] as? String
            let clubAbbreviation = value?["club_abbreviation"] as? String
            self.ClubDescriptionLabel.text = clubDescriptionLabel!
            self.navigationItem.title = clubName
            //self.ClubNameLabel.text = value?["club_name"] as? String ?? "ClubName"
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
        
        ClubMemberView.isHidden = false
        ClubEventView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func doClubButtonAction(_ sender: Any) {
        if isAdmin {
            performSegue(withIdentifier: "editClub", sender: self)
        }
        else if isMember {
            ref.child("users").child(Auth.auth().currentUser!.uid).child("clubs").child(ClubKey).removeValue()
            ref.child("clubs").child(ClubKey).child("members").child(Auth.auth().currentUser!.uid).removeValue()

            ClubButton.setTitle("Join Club", for: .normal)
            isMember = false
        }
        else {
            let club: [AnyHashable: Any] = [ClubKey: true]
            ref.child("users").child(Auth.auth().currentUser!.uid).child("clubs").updateChildValues(club)
            
            let member: [AnyHashable: Any] = [(Auth.auth().currentUser!.uid): true]
            ref.child("clubs").child(ClubKey).child("members").updateChildValues(member)
            
            ClubButton.setTitle("Leave Club", for: .normal)
            isMember = true
        }
    }
    
    @objc func addEvent() {
        performSegue(withIdentifier: "addClubEvent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        if segue.identifier == "addClubEvent" {
            let secondViewController = segue.destination as! CreateClubEventViewController
            secondViewController.ClubKey = ClubKey
        }
        
        if segue.identifier == "memberTableSegue" {
            let secondViewController = segue.destination as! MembersTableViewController
            secondViewController.ClubKey = ClubKey
        }
        
        if segue.identifier == "eventTableSegue" {
            let secondViewController = segue.destination as! EventsTableViewController
            secondViewController.ClubKey = ClubKey
        }
        
        if segue.identifier == "viewAnalytics" {
            let secondViewController = segue.destination as! AnalyticsViewController
            secondViewController.ClubKey = ClubKey
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch ClubSegmentControl.selectedSegmentIndex {
        case 0:
            ClubMemberView.isHidden = false
            ClubEventView.isHidden = true
            break
        case 1:
            ClubMemberView.isHidden = true
            ClubEventView.isHidden = false
            break
        default:
            break
        }
    }
    

    @IBAction func viewAnalytics(_ sender: Any) {
    }
    
    
    
}

extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        color.set()
        withRenderingMode(.alwaysOriginal)
            .draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

class MemberTableCell: UITableViewCell {
    @IBOutlet weak var TableCellImage: UIImageView!
    override func layoutSubviews() {
        TableCellImage.layer.cornerRadius = TableCellImage.bounds.height / 2
        TableCellImage.clipsToBounds = true
        TableCellImage.layer.borderWidth = 1
        TableCellImage.contentMode = .scaleAspectFill
    }
}
