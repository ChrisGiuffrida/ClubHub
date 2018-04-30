//
//  CreateNewClubViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class CreateNewClubViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var ClubNameTextField: UITextField!
    @IBOutlet weak var ClubAbbreviationTextField: UITextField!
    @IBOutlet weak var ClubDescriptionTextView: UITextView!
    @IBOutlet weak var ClubImageView: UIImageView!
    @IBOutlet weak var CreateClubButton: UIButton!
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var ClubKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        configureStorage()
        ClubImageView.layer.borderWidth = 1
        ClubImageView.layer.masksToBounds = false
        ClubImageView.layer.cornerRadius = ClubImageView.frame.height/2
        ClubImageView.clipsToBounds = true
        ClubImageView.contentMode = .scaleAspectFill;

        
        ClubDescriptionTextView.delegate = self
        ClubDescriptionTextView.text = "Club description..."
        ClubDescriptionTextView.textColor = UIColor.groupTableViewBackground
        ClubDescriptionTextView!.layer.borderWidth = 0.5
        ClubDescriptionTextView.layer.cornerRadius = 5
        ClubDescriptionTextView!.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        ClubNameTextField!.layer.borderWidth = 0.5
        ClubNameTextField.layer.cornerRadius = 5
        ClubNameTextField!.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        ClubAbbreviationTextField!.layer.borderWidth = 0.5
        ClubAbbreviationTextField.layer.cornerRadius = 5
        ClubAbbreviationTextField!.layer.borderColor = UIColor.groupTableViewBackground.cgColor

        self.addRemoveKeyboardGesture()
        CreateClubButton.isEnabled = false
        
        ClubNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        ClubAbbreviationTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        //ClubDescriptionTextView.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.groupTableViewBackground {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Club description..."
            textView.textColor = UIColor.groupTableViewBackground
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func editingChanged() {
        guard
            let clubName = ClubNameTextField.text, !clubName.isEmpty,
            let clubAbbrev = ClubAbbreviationTextField.text, !clubAbbrev.isEmpty
            //let clubDescription = ClubDescriptionTextView.text, !clubDescription.isEmpty
            else {
                self.CreateClubButton.isEnabled = false
                return
        }
        CreateClubButton.isEnabled = true
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
    
    func saveClubPhoto(photoData: Data, ClubKey: String) {
        let imagePath = "club_photos/" + ClubKey

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        // create a child node at imagePath with imageData and metadata
        storageRef!.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            let members: [AnyHashable: Any] = ["photo_url": imagePath]
            self.ref.child("clubs").child(self.ClubKey).updateChildValues(members)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let secondViewController = segue.destination as! ClubViewController
        
        // set a variable in the second view controller with the String to pass
        secondViewController.ClubKey = ClubKey
    }
    
    @IBAction func createClub(_ sender: Any) {
        if user != nil {
            ClubKey = ref.child("clubs").childByAutoId().key
            let admin: [AnyHashable: Any] = [(self.user?.uid)!: true]
            self.ref.child("clubs").child(ClubKey).setValue(["club_name": ClubNameTextField.text, "club_abbreviation": ClubAbbreviationTextField.text, "club_description": ClubDescriptionTextView.text, "admins": admin])
            
            let clubs: [AnyHashable: Any] = [ClubKey: true]
            self.ref.child("users").child((self.user?.uid)!).child("admin_clubs").updateChildValues(clubs)
            
            let Data = UIImageJPEGRepresentation(ClubImageView.image!, 0.8)
            saveClubPhoto(photoData: Data!, ClubKey: ClubKey)
            
            //performSegue(withIdentifier: "goToNewClub", sender: self)
        }
    }

    
    @IBAction func selectImage(_ sender: Any) {
        ClubNameTextField.resignFirstResponder()
    ClubDescriptionTextView.resignFirstResponder()
        ClubNameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set club image view to display the selected image.
        ClubImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}

extension UIViewController
{
    func addRemoveKeyboardGesture()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
