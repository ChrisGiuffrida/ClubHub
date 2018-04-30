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

class ActivityTableViewController: UITableViewController {
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _friendHandle: DatabaseHandle!
    
    var events: [(ClubInfo: (ClubKey: String, ClubName: String), EventInfo: (EventKey: String, EventName: String, EventDescription: String))]! = []
    var EventsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventsTable = self.tableView
        
        configureAuth()
        configureDatabase()
        configureStorage()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        
        _friendHandle = ref.child("users").child(Auth.auth().currentUser!.uid).child("events").observe(.childAdded) { (snapshot: DataSnapshot) in
            let eventSnapshot = snapshot.key as! String
            
            let eventInfoArray = eventSnapshot.components(separatedBy: "|")
            let clubKey = eventInfoArray[0]
            let eventKey = eventInfoArray[1]
            
            self.ref.child("clubs").child(clubKey).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let clubName = value?["club_name"] as? String
                self.ref.child("clubs").child(clubKey).child("events").child(eventKey).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let eventName = value?["event_name"] as? String
                    let eventDescription = "The Description"

                    self.events.append((ClubInfo: (ClubKey: clubKey, ClubName: clubName!), (EventKey: eventKey, EventName: eventName!, EventDescription: eventDescription)))
                    self.EventsTable.insertRows(at: [IndexPath(row: self.events.count-1, section: 0)], with: .automatic)
                }) { (error) in
                    print(error.localizedDescription)
                }
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
        ref.child("users").child(Auth.auth().currentUser!.uid).child("events").removeObserver(withHandle: _friendHandle)
        //Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = EventsTable.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let event = events[indexPath.row]
        cell!.textLabel?.text = event.ClubInfo.ClubName + ": " + event.EventInfo.EventName
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
