//
//  HomeViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var CreateClubButton: UIButton!
    @IBOutlet weak var LogOutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LogOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: "LogOut", sender: sender)
    }
    
    
    @IBAction func createNewClub(_ sender: Any) {
        performSegue(withIdentifier: "createClub", sender: self)
    }
}

