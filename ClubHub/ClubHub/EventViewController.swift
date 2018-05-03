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

class EventViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var EventsTableView: UITableView!
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    fileprivate var _refHandle: DatabaseHandle!
    
    var events: [(EventName: String, EventPicture: UIImage, EventDescription: String, EventLocation: String, EventTime: Double)]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
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
        
        _refHandle = ref.child("users").child(Auth.auth().currentUser!.uid).child("events").observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let eventInfo = snapshot.key as String
            
            let eventInfoArray = eventInfo.components(separatedBy: "|")
            let ClubKey = eventInfoArray[0]
            let EventKey = eventInfoArray[1]

            self.ref.child("clubs").child(ClubKey).child("events").child(EventKey).observeSingleEvent(of: .value, with: {(snapshot) in
                let dictionary = snapshot.value as! NSDictionary
                var event_name = dictionary["event_name"]! as! String
                var event_time = dictionary["event_time"]! as! Double
                var event_location = dictionary["event_location"]! as! String
                var event_description = dictionary["event_description"]! as! String

                let photo_url = "club_photos/" + ClubKey
                let pictureRef = self.storageRef.child(photo_url)
                // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
                pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        self.events.append((EventName: event_name, EventPicture: image!, EventDescription: event_description, EventLocation: event_location, EventTime: event_time))
                        self.EventsTableView.insertRows(at: [IndexPath(row: self.events.count-1, section: 0)], with: .automatic)
                    }
                }
            })
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
        let cell: UITableViewCell! = EventsTableView.dequeueReusableCell(withIdentifier: "eventTabCell", for: indexPath)
        let eventInfo = events[indexPath.row]
        let labelView = cell.viewWithTag(2) as! UILabel!
        labelView?.text = eventInfo.EventName
        let imageView = cell.viewWithTag(1) as! UIImageView?
        imageView?.image = eventInfo.EventPicture
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let secondViewController = segue.destination as! ClubViewController
//        secondViewController.ClubKey = ClubKey
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventName = events[indexPath.row].EventName
        let eventDescription = events[indexPath.row].EventDescription
        let dateTime = Date(timeIntervalSince1970: events[indexPath.row].EventTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let dateTimeString = formatter.string(from: dateTime)
        let message = "Location: " + events[indexPath.row].EventLocation + "\n\n" + "Time: " + dateTimeString + "\n\n" + "Event Description: " + eventDescription
        let alertVC = UIAlertController(title: eventName, message: message, preferredStyle: .alert)
        let alertActionOkay = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertVC.addAction(alertActionOkay)
        self.present(alertVC, animated: true)
    }
}

class EventTableCell: UITableViewCell {
    
    @IBOutlet weak var TableCellImage: UIImageView!
    override func layoutSubviews() {
        TableCellImage.layer.cornerRadius = TableCellImage.bounds.height / 2
        TableCellImage.clipsToBounds = true
        TableCellImage.layer.borderWidth = 1
        TableCellImage.contentMode = .scaleAspectFill
    }
}

