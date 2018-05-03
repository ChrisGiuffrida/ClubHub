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

    
    var members: [(MemberKey: String, MemberName: String, ProfilePicture: UIImage)]! = []
    var MembersTable: UITableView!
    
    var ClubKey: String = ""
    var UserID: String = ""
    
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
                
                let pictureRef = self.storageRef.child("user_photos/" + memberKey)
                // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
                pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print(error.localizedDescription)
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        self.members.append((MemberKey: memberKey, MemberName: memberName, ProfilePicture: image!))
                        self.MembersTable.insertRows(at: [IndexPath(row: self.members.count-1, section: 0)], with: .automatic)
                    }
                }
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
        let imageView = cell.viewWithTag(1) as! UIImageView!
        imageView?.image = memberInfo.ProfilePicture
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.members.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondViewController = segue.destination as! ProfileViewController
        // set a variable in the second view controller with the String to pass
        secondViewController.UserID = UserID
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserID = members[indexPath.row].MemberKey
        performSegue(withIdentifier: "clubMemberProfile", sender: self)
    }
}
