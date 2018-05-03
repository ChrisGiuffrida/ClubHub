//
//  EventViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class HomeViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var EventsTableView: UITableView!
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _refHandle: DatabaseHandle!
    
    var events: [(EventName: String, ProfilePicture: UIImage, PersonName: String, EventTime: String)]! = []
    var event_names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hey")
        configureAuth()
        print("hey again")
        configureDatabase()
        print("and again")
        configureStorage()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.EventsTableView.dataSource = self
        self.EventsTableView.delegate = self
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        print("Configuring")
        _refHandle = ref.child("users").child(Auth.auth().currentUser!.uid).child("following").observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let user = snapshot.key as String
                self.ref.child("users").child(user).observe(.value, with: { (snapshot2: DataSnapshot) in
                    let user_info = snapshot2.value as! NSDictionary
                    let user_name = (user_info["firstName"] as! String) + " " + (user_info["lastName"] as! String)
                    if user_info["events"] != nil {
                        print(user_info["events"])
                        let user_events = user_info["events"] as! [String: Bool]
                        for user_event in user_events.keys {
                            let eventInfo = user_event
                            let eventInfoArray = eventInfo.components(separatedBy: "|")
                            let ClubKey = eventInfoArray[0]
                            let EventKey = eventInfoArray[1]
                            self.ref.child("clubs").child(ClubKey).child("events").child(EventKey).observeSingleEvent(of: .value, with: {(snapshot3) in
                                let dictionary = snapshot3.value as! NSDictionary
                                let event_name = dictionary["event_name"]! as! String
                                let event_time = dictionary["event_time"]! as! Double
                                
                                let photo_url = "user_photos/" + (user as! String)
                                let pictureRef = self.storageRef.child(photo_url)
                                // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
                                pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                                    if let error = error {
                                        // Uh-oh, an error occurred!
                                    } else {
                                        // Data for "images/island.jpg" is returned
                                        let image = UIImage(data: data!)
                                        let dateTime = Date(timeIntervalSince1970: event_time)
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
                                        let dateTimeString = formatter.string(from: dateTime)
                                        if !(self.event_names.contains(event_name + user)){
                                            self.event_names.append(event_name + user)
                                            self.events.append((EventName: event_name, ProfilePicture: image!, PersonName: user_name, EventTime: dateTimeString))
                                            self.EventsTableView.insertRows(at: [IndexPath(row: self.events.count-1, section: 0)], with: .automatic)
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
                )
        })
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = EventsTableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath)
        let eventInfo = events[indexPath.row]
        let eventNameLabel = cell.viewWithTag(2) as! UILabel!
        let eventTimeLabel = cell.viewWithTag(3) as! UILabel!
        eventNameLabel?.text = eventInfo.PersonName + " signed in to " + eventInfo.EventName + "."
        eventTimeLabel?.text = eventInfo.EventTime
        let imageView = cell.viewWithTag(1) as! UIImageView?
        imageView?.image = eventInfo.ProfilePicture
        
        return cell!
    }
    
}

class HomeTableCell: UITableViewCell {
    @IBOutlet weak var HomeTableImage: UIImageView!
    override func layoutSubviews() {
        HomeTableImage.layer.cornerRadius = HomeTableImage.bounds.height / 2
        HomeTableImage.clipsToBounds = true
        HomeTableImage.layer.borderWidth = 1
        HomeTableImage.contentMode = .scaleAspectFill
    }
}
