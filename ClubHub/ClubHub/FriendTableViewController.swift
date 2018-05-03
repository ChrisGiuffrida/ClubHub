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

class FriendTableViewController: UITableViewController {
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _friendHandle: DatabaseHandle!
    fileprivate var _friendsHandleDelete: DatabaseHandle!
    
    var friends: [(FriendKey: String, FriendName: String, FriendPicture: UIImage)]! = []
    var FriendsTable: UITableView!
    
    var UserID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FriendsTable = self.tableView
        
        configureAuth()
        configureDatabase()
        configureStorage()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        print("UserID: " + UserID)
        _friendHandle = ref.child("users").child(UserID).child("following").observe(.childAdded) { (snapshot: DataSnapshot) in
            let friendKey = snapshot.key as! String
            self.ref.child("users").child(friendKey).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let firstName = value?["firstName"] as? String
                let lastName = value?["lastName"] as? String
                let friendName = firstName! + " " + lastName!
                
                let pictureRef = self.storageRef.child("user_photos/" + friendKey)
                // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
                pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print(error.localizedDescription)
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        self.friends.append((FriendKey: friendKey, FriendName: friendName, FriendPicture: image!))
                        self.FriendsTable.insertRows(at: [IndexPath(row: self.friends.count-1, section: 0)], with: .automatic)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        _friendsHandleDelete = ref.child("users").child(UserID).child("following").observe(.childRemoved) { (snapshot: DataSnapshot) in
            for (index, friend) in self.friends.enumerated() {
                if snapshot.key == friend.FriendKey {
                    self.friends.remove(at: index)
                }
            }
            self.FriendsTable.reloadData()
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
        ref.child("users").child(UserID).child("following").removeObserver(withHandle: _friendHandle)
        ref.child("users").child(UserID).child("following").removeObserver(withHandle: _friendsHandleDelete)
        //Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = FriendsTable.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        let friendInfo = friends[indexPath.row]
        let labelView = cell.viewWithTag(2) as! UILabel!
        labelView?.text = friendInfo.FriendName
        let imageView = cell.viewWithTag(1) as! UIImageView!
        imageView?.image = friendInfo.FriendPicture
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

class FriendTableCell: UITableViewCell {
    @IBOutlet weak var TableCellImage: UIImageView!
    override func layoutSubviews() {
        TableCellImage.layer.cornerRadius = TableCellImage.bounds.height / 2
        TableCellImage.clipsToBounds = true
        TableCellImage.layer.borderWidth = 1
        TableCellImage.contentMode = .scaleAspectFill
    }
}
