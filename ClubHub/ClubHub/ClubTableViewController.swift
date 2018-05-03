//
//  ClubTableViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/29/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ClubTableViewController: UITableViewController {
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _clubHandle: DatabaseHandle!
    fileprivate var _clubsHandleDelete: DatabaseHandle!
    
    var clubs: [(ClubKey: String, ClubName: String, ClubPicture: UIImage)]! = []
    var ClubsTable: UITableView!
    
    var UserID: String = ""
    
    var ClubKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClubsTable = self.tableView
        
        configureAuth()
        configureDatabase()
        configureStorage()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        print("UserID: " + UserID)
        _clubHandle = ref.child("users").child(UserID).child("clubs").observe(.childAdded) { (snapshot: DataSnapshot) in
            let clubKey = snapshot.key as! String
            self.ref.child("clubs").child(clubKey).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let clubName = value?["club_name"] as? String ?? "Club"
                
                let pictureRef = self.storageRef.child("club_photos/" + clubKey)
                // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
                pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print(error.localizedDescription)
                    } else {
                        // Data for "images/island.jpg" is returned
                        var image = UIImage(data: data!)
                        self.clubs.append((ClubKey: clubKey, ClubName: clubName, ClubPicture: image!))
                        self.ClubsTable.insertRows(at: [IndexPath(row: self.clubs.count-1, section: 0)], with: .automatic)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        _clubsHandleDelete = ref.child("users").child(UserID).child("clubs").observe(.childRemoved) { (snapshot: DataSnapshot) in
            for (index, club) in self.clubs.enumerated() {
                if snapshot.key == club.ClubKey {
                    self.clubs.remove(at: index)
                }
            }
            self.ClubsTable.reloadData()
        }
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
    
    deinit {
        ref.child("users").child(UserID).child("clubs").removeObserver(withHandle: _clubHandle)
        ref.child("users").child(UserID).child("clubs").removeObserver(withHandle: _clubsHandleDelete)
        //Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = ClubsTable.dequeueReusableCell(withIdentifier: "clubCell", for: indexPath)
        let clubInfo = clubs[indexPath.row]        
        let labelView = cell.viewWithTag(2) as! UILabel!
        labelView?.text = clubInfo.ClubName
        let imageView = cell.viewWithTag(1) as! UIImageView!
        imageView?.image = clubInfo.ClubPicture
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clubs.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondViewController = segue.destination as! ClubViewController
        secondViewController.ClubKey = ClubKey
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ClubKey = clubs[indexPath.row].ClubKey
        performSegue(withIdentifier: "profileToClubSegue", sender: self)
    }
}
