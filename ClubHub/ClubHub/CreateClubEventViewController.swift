//
//  CreateClubEventViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import QRCode

class CreateClubEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var LocationTextField: UITextField!
    @IBOutlet weak var DateTextField: customTextField!
    @IBOutlet weak var AddEventButton: UIButton!
    @IBOutlet weak var EventNameTextField: UITextField!
    @IBOutlet weak var EventDescriptionTextView: UITextView!
    //@IBOutlet weak var QRCodeImage: UIImageView!
    var ref: DatabaseReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var ClubEventKey: String = ""
    var ClubKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        
        EventDescriptionTextView.delegate = self
        EventDescriptionTextView.text = "Event description..."
        EventDescriptionTextView.textColor = UIColor.groupTableViewBackground
        EventDescriptionTextView!.layer.borderWidth = 0.5
        EventDescriptionTextView.layer.cornerRadius = 5
        EventDescriptionTextView!.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        self.addRemoveKeyboardGesture()
        //FinishSignUpButton.isEnabled = false
        
        //FirstNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        //LastNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    @objc func editingChanged() {
    //        guard
    //            let firstName = FirstNameTextField.text, !firstName.isEmpty,
    //            let lastName = LastNameTextField.text, !lastName.isEmpty
    //            else {
    //                self.FinishSignUpButton.isEnabled = false
    //                return
    //        }
    //        FinishSignUpButton.isEnabled = true
    //    }
    
    func configureDatabase() {
        ref = Database.database().reference()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let secondViewController = segue.destination as! QRCodeViewController
        
        // set a variable in the second view controller with the String to pass
        secondViewController.text = ClubKey + "#" + ClubEventKey
        secondViewController.ClubKey = ClubKey
    }
    
    @IBAction func textFieldEditing(_ sender: customTextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        let datePicker: UIDatePicker = UIDatePicker()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        DateTextField.inputAccessoryView = toolBar
        DateTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    @IBAction func addNewEvent(_ sender: Any) {
        let epochFormatter = DateFormatter()
        epochFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let date_epoch = epochFormatter.date(from: DateTextField.text!)?.timeIntervalSince1970
        ClubEventKey = ref.child("clubs").child(ClubKey).childByAutoId().key
        self.ref.child("clubs").child(ClubKey).child("events").child(ClubEventKey).setValue(["event_name": EventNameTextField.text, "event_description": EventDescriptionTextView.text, "event_time": date_epoch, "event_location": LocationTextField.text])
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        DateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func donePicker() {
        DateTextField.resignFirstResponder()
    }
    
    @objc func cancelPicker() {
            DateTextField.text = ""
            DateTextField.resignFirstResponder()
    }
}

//extension UIViewController
//{
//    func addRemoveKeyboardGesture()
//    {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
//            target: self,
//            action: #selector(UIViewController.dismissKeyboard))
//
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc func dismissKeyboard()
//    {
//        view.endEditing(true)
//    }
//}

