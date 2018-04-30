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
    
    var clubs: [(ClubKey: String, ClubName: String)]! = []
    var ClubsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClubsTable = self.tableView
        
        configureAuth()
        configureDatabase()
        configureStorage()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        
        _clubHandle = ref.child("users").child(Auth.auth().currentUser!.uid).child("clubs").observe(.childAdded) { (snapshot: DataSnapshot) in
            let clubKey = snapshot.key as! String
            self.ref.child("clubs").child(clubKey).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let clubName = value?["club_name"] as? String ?? "Club"
                self.clubs.append((ClubKey: clubKey, ClubName: clubName))
                self.ClubsTable.insertRows(at: [IndexPath(row: self.clubs.count-1, section: 0)], with: .automatic)
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
        ref.child("users").child(Auth.auth().currentUser!.uid).child("clubs").removeObserver(withHandle: _clubHandle)
        //Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = ClubsTable.dequeueReusableCell(withIdentifier: "clubCell", for: indexPath)
        let clubInfo = clubs[indexPath.row]
        cell!.textLabel?.text = clubInfo.ClubName
        
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clubs.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
