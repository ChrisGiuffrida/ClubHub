//
//  YourClubsViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class YourClubsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var YourClubsTableView: UITableView!
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    var clubs: [(ClubName: String, ClubPicture: UIImage, ClubKey: String)]! = []
    
    var ClubKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        configureStorage()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.YourClubsTableView.dataSource = self
        self.YourClubsTableView.delegate = self
        
        ref.child("users").child(Auth.auth().currentUser!.uid).child("admin_clubs").observeSingleEvent(of: .value, with: {(snapshot) in
            for club in snapshot.children {
                let club = club as? DataSnapshot
                let ClubKey = club?.key as! String
                print(ClubKey)
                self.ref.child("clubs").child(ClubKey).observeSingleEvent(of: .value, with: {(snapshot) in
                        let dictionary = snapshot.value as! NSDictionary
                        var club_name = dictionary["club_name"]! as! String
                        var photo_url = dictionary["photo_url"]! as! String

                        let pictureRef = self.storageRef.child(photo_url)
                        // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
                        pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                            if let error = error {
                                // Uh-oh, an error occurred!
                            } else {
                                // Data for "images/island.jpg" is returned
                                let image = UIImage(data: data!)
                                self.clubs.append((ClubName: club_name, ClubPicture: image!, ClubKey: ClubKey))
                                self.YourClubsTableView.insertRows(at: [IndexPath(row: self.clubs.count-1, section: 0)], with: .automatic)
                            }
                        }

                })
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
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
        return self.clubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = YourClubsTableView.dequeueReusableCell(withIdentifier: "yourClubCell", for: indexPath)
        let clubInfo = clubs[indexPath.row]
        let labelView = cell.viewWithTag(2) as! UILabel!
        labelView?.text = clubInfo.ClubName
        let imageView = cell.viewWithTag(1) as! UIImageView?
        imageView?.image = clubInfo.ClubPicture
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondViewController = segue.destination as! ClubViewController
        secondViewController.ClubKey = ClubKey
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ClubKey = clubs[indexPath.row].ClubKey
        performSegue(withIdentifier: "showClubFromAdmin", sender: self)
    }
}

class YourClubsTableCell: UITableViewCell {
    @IBOutlet weak var TableCellImage: UIImageView!
    override func layoutSubviews() {
        TableCellImage.layer.cornerRadius = TableCellImage.bounds.height / 2
        TableCellImage.clipsToBounds = true
        TableCellImage.layer.borderWidth = 1
        TableCellImage.contentMode = .scaleAspectFill
    }
}

