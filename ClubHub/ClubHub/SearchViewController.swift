//
//  SearchViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    var lookingAtClubs: Bool = true
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    var clubs: [(ClubName: String, ClubPicture: UIImage, ClubKey: String)]! = []
    var people: [(Name: String, ProfilePicture: UIImage, UserID: String)]! = []
    
    var ClubKey: String = ""
    var UserID:  String = ""

    
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var SearchResultsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        configureStorage()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.SearchBar.delegate = self
        self.SearchResultsTable.dataSource = self
        self.SearchResultsTable.delegate = self
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query = SearchBar.text
        
        if query == "" {
            self.view.endEditing(true)
            return
        }
        people = []
        clubs  = []
        SearchResultsTable.reloadData()

        if SearchBar.selectedScopeButtonIndex == 0 {
            ref.child("clubs").queryOrdered(byChild: "club_name").queryStarting(atValue: query, childKey: "club_name").queryEnding(atValue: query! + "\u{f8ff}").observeSingleEvent(of: .value, with: {(snapshot) in
                for child in snapshot.children {
                    let child = child as? DataSnapshot
                    if let key = child?.key {
                        if let dictionary = child?.value as? [String: AnyObject] {
                            var club_name = dictionary["club_name"]! as! String
                            var photo_url = dictionary["photo_url"]! as! String
                            
                            let pictureRef = self.storageRef.child(photo_url)
                            // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
                            pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                                if let error = error {
                                    // Uh-oh, an error occurred!
                                } else {
                                    // Data for "images/island.jpg" is returned
                                    self.lookingAtClubs = true
                                    let image = UIImage(data: data!)
                                    self.clubs.append((ClubName: club_name, ClubPicture: image!, ClubKey: key))
                                    self.SearchResultsTable.insertRows(at: [IndexPath(row: self.clubs.count-1, section: 0)], with: .automatic)
                                }
                            }
                        }
                    }
                }
            })
        }
        else {
            ref.child("users").queryOrdered(byChild: "firstName").queryStarting(atValue: query, childKey: "first_name").queryEnding(atValue: query! + "\u{f8ff}").observeSingleEvent(of: .value, with: {(snapshot) in
                for child in snapshot.children {
                    let child = child as? DataSnapshot
                    if let key = child?.key {
                        if let dictionary = child?.value as? [String: AnyObject] {
                            var first_name = dictionary["firstName"]! as! String
                            var last_name = dictionary["lastName"]! as! String
                            var photo_url = dictionary["photo_url"]! as! String
                            
                            let pictureRef = self.storageRef.child(photo_url)
                            // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
                            pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                                if let error = error {
                                    // Uh-oh, an error occurred!
                                } else {
                                    // Data for "images/island.jpg" is returned
                                    self.lookingAtClubs = false
                                    let image = UIImage(data: data!)
                                    if key != Auth.auth().currentUser!.uid {
                                        self.people.append((Name: first_name + " " + last_name, ProfilePicture: image!, UserID: key))
                                        print(first_name)
                                        self.SearchResultsTable.insertRows(at: [IndexPath(row: self.people.count-1, section: 0)], with: .automatic)
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SearchBar.selectedScopeButtonIndex == 0 {
            return self.clubs.count
        }
        else {
            return self.people.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = SearchResultsTable.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        if SearchBar.selectedScopeButtonIndex == 0 {
            let clubInfo = clubs[indexPath.row]
            let labelView = cell.viewWithTag(2) as! UILabel!
            labelView?.text = clubInfo.ClubName
            let imageView = cell.viewWithTag(1) as! UIImageView?
            imageView?.image = clubInfo.ClubPicture
        }
        else {
            let personInfo = people[indexPath.row]
            let labelView = cell.viewWithTag(2) as! UILabel!
            labelView?.text = personInfo.Name
            let imageView = cell.viewWithTag(1) as! UIImageView?
            imageView?.image = personInfo.ProfilePicture
        }
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        if lookingAtClubs {
            let secondViewController = segue.destination as! ClubViewController
            
            // set a variable in the second view controller with the String to pass
            secondViewController.ClubKey = ClubKey
        }
        else {
            let secondViewController = segue.destination as! ProfileViewController
            secondViewController.UserID = UserID
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lookingAtClubs {
            ClubKey = clubs[indexPath.row].ClubKey
            performSegue(withIdentifier: "clubSegue", sender: self)
        } else {
            UserID = people[indexPath.row].UserID
            performSegue(withIdentifier: "profileSegue", sender: self)
        }
    }
}

class CustomTableCell: UITableViewCell {
    @IBOutlet weak var TableCellImage: UIImageView!
    override func layoutSubviews() {
        TableCellImage.layer.cornerRadius = TableCellImage.bounds.height / 2
        TableCellImage.clipsToBounds = true
        TableCellImage.layer.borderWidth = 1
        TableCellImage.contentMode = .scaleAspectFill
    }
}

