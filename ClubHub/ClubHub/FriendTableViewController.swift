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
    
    var friends: [(FriendKey: String, FriendName: String)]! = []
    var FriendsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FriendsTable = self.tableView
        
        configureAuth()
        configureDatabase()
        configureStorage()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        
        _friendHandle = ref.child("users").child(Auth.auth().currentUser!.uid).child("friends").observe(.childAdded) { (snapshot: DataSnapshot) in
            let friendKey = snapshot.key as! String
            self.ref.child("users").child(friendKey).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let firstName = value?["firstName"] as? String
                let lastName = value?["lastName"] as? String
                let friendName = firstName! + " " + lastName!
                self.friends.append((FriendKey: friendKey, FriendName: friendName))
                self.FriendsTable.insertRows(at: [IndexPath(row: self.friends.count-1, section: 0)], with: .automatic)
            }) { (error) in
                print(error.localizedDescription)
            }
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
        ref.child("users").child(Auth.auth().currentUser!.uid).child("friends").removeObserver(withHandle: _friendHandle)
        //Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = FriendsTable.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        let friendInfo = friends[indexPath.row]
        cell!.textLabel?.text = friendInfo.FriendName
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
