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

class EventsTableViewController: UITableViewController {
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _eventsHandle: DatabaseHandle!

    var events: [(EventName: String, EventDescription: String)]! = []
    var EventsTable: UITableView!
    
    var ClubKey: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        EventsTable = self.tableView
        self.EventsTable.delegate = self
        
        configureAuth()
        configureDatabase()
        configureStorage()
    }

    func configureDatabase() {
        ref = Database.database().reference()

        _eventsHandle = ref.child("clubs").child(ClubKey).child("events").observe(.childAdded) { (snapshot: DataSnapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let eventName = value?["event_name"] as? String
            let eventDescription = value?["event_description"] as? String
            
            self.events.append((EventName: eventName!, EventDescription: eventDescription!))
            self.EventsTable.insertRows(at: [IndexPath(row: self.events.count-1, section: 0)], with: .automatic)
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
        ref.child("clubs").child(ClubKey).child("events").removeObserver(withHandle: _eventsHandle)
        //Auth.auth().removeStateDidChangeListener(_authHandle)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = EventsTable.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let eventInfo = events[indexPath.row]
        let labelView = cell.viewWithTag(1) as! UILabel!
        labelView?.text = eventInfo.EventName
        return cell!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventName = events[indexPath.row].EventName
        let eventDescription = events[indexPath.row].EventDescription
        let alertVC = UIAlertController(title: eventName, message: eventDescription, preferredStyle: .alert)
        let alertActionOkay = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertVC.addAction(alertActionOkay)
        self.present(alertVC, animated: true)
    }
}
