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

class MembersTableViewController: UITableViewController {
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _membersHandle: DatabaseHandle!
    fileprivate var _membersHandleDelete: DatabaseHandle!

    
    var members: [(MemberKey: String, MemberName: String)]! = []
    var MembersTable: UITableView!
    
    var ClubKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MembersTable = self.tableView
        
        configureAuth()
        configureDatabase()
        configureStorage()
    }
    
    func setClubKey(ClubKey: String) {
        self.ClubKey = ClubKey
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        
        _membersHandle = ref.child("clubs").child(ClubKey).child("members").observe(.childAdded) { (snapshot: DataSnapshot) in
            let memberKey = snapshot.key as! String
            self.ref.child("users").child(memberKey).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let firstName = value?["firstName"] as? String
                let lastName = value?["lastName"] as? String
                let memberName = firstName! + " " + lastName!
                self.members.append((MemberKey: memberKey, MemberName: memberName))
                self.MembersTable.insertRows(at: [IndexPath(row: self.members.count-1, section: 0)], with: .automatic)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        _membersHandleDelete = ref.child("clubs").child(ClubKey).child("members").observe(.childRemoved) { (snapshot: DataSnapshot) in
            for (index, member) in self.members.enumerated() {
                if snapshot.key == member.MemberKey {
                    self.members.remove(at: index)
                }
            }
            self.MembersTable.reloadData()
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
        ref.child("clubs").child(ClubKey).child("members").removeObserver(withHandle: _membersHandle)
        ref.child("clubs").child(ClubKey).child("members").removeObserver(withHandle: _membersHandleDelete)
        //Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = MembersTable.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath)
        let memberInfo = members[indexPath.row]
        let labelView = cell.viewWithTag(2) as! UILabel!
        labelView?.text = memberInfo.MemberName
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.members.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
