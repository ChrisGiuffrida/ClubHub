//
//  CompleteSignupViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class customTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.select(_:)) ||
            action == #selector(UIResponderStandardEditActions.selectAll(_:)) ||
            action == #selector(UIResponderStandardEditActions.cut(_:)) ||
            action == #selector(UIResponderStandardEditActions.copy(_:)){
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

class CompleteSignupViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var FinishSignUpButton: UIButton!
    @IBOutlet weak var GenderTextField: customTextField!
    @IBOutlet weak var CollegeTextField: customTextField!
    @IBOutlet weak var MajorTextField: customTextField!
    @IBOutlet weak var ResidenceHallTextField: customTextField!
    @IBOutlet weak var GraduationYearTextField: customTextField!
    
    @IBOutlet weak var EditProfileButton: UIButton!
    var editingProfile: Bool = false
    
    let genders = ["Male", "Female", "Other"]
    
    let colleges = ["College of Arts and Letters", "College of Business", "College of Engineering", "College of Science", "School of Architecture"]
    
    let dorms = ["Alumni Hall", "Badin Hall", "Breen-Phillips Hall", "Carroll Hall", "Cavanaugh Hall", "Dillon Hall", "Duncan Hall", "Dunne Hall", "Farley Hall", "Fisher Hall", "Flaherty Hall", "Howard Hall", "Keenan Hall", "Keough Hall", "Knott Hall", "Lewis Hall", "Lyons Hall", "McGlinn Hall", "Morrissey Hall", "O'Neill Hall", "Pangborn Hall", "Pasquerilla East Hall", "Pasquerilla West Hall", "Ryan Hall", "St. Edwards's Hall", "Siegfried Hall", "Sorin Hall", "Stanford Hall", "Walsh Hall", "Welsh Family Hall", "Zahm Hall", "Off Campus"]
    
    let majors = ["Accountancy", "Aerospace Engineering", "Africana Studies", "American Studies", "Anthropology", "Applied and Computational Mathematics and Statistics", "Arabic Studies", "Architecture", "Art History", "Biochemistry", "Biological Sciences", "Chemical Engineering", "Chemistry", "Chemistry/Business", "Chemistry/Computing", "Chinese", "Civil Engineering", "Classics", "Computer Engineering", "Computer Science", "Design", "Economics", "Electrical Engineering", "English", "Environmental Earth Sciences", "Environmental Engineering", "Environmental Sciences", "Film, Television, and Theatre", "Finance", "French and Francophone Studies", "Gender Studies", "German", "Greek and Roman Civilization", "History", "Information Technology, Analytics, and Operations", "International Economics", "Irish Language and Literature", "Italian Studies", "Japanese", "Management & Organization", "Marketing", "Mathematics", "Mathematics", "Mechanical Engineering", "Medieval Studies", "Music", "Neuroscience and Behavior", "Neuroscience and Behavior", "Philosophy and Theology (joint major)", "Physics", "Physics in Medicine", "Political Science", "Preprofessional Studies", "Program of Liberal Studies", "Psychology", "Romance Languages and Literatures", "Russian", "Science-Business", "Science-Computing", "Science-Education", "Self-Designed Majors", "Sociology", "Spanish", "Statistics", "Studio Art", "Theology"]
    
    let graduationYears = ["2018", "2019", "2020", "2021", "2022"]

    var activeDataArray = [String]()
    var pickerView = UIPickerView()
    
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    var user: User?
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    override func viewWillAppear(_ animated: Bool) {
        if isEditing {
            EditProfileButton.setTitle("Submit Changes", for: .normal)
            self.navigationItem.title = "Edit Profile"
            
            ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let grad_year = value?["grad_year"] as? String ?? "GradYear"
                let major = value?["major"] as? String ?? "Major"
                let college = value?["college"] as? String ?? "College"
                let university = "University of Notre Dame"
                let firstName = value?["firstName"] as? String
                let lastName = value?["lastName"] as? String
                let gender = value?["gender"] as? String
                let residence = value?["dorm"] as? String
                
                
                self.FirstNameTextField.text = firstName
                self.LastNameTextField.text = lastName
                self.MajorTextField.text = major
                self.CollegeTextField.text = college
                self.GenderTextField.text = gender
                self.ResidenceHallTextField.text = residence
                self.GraduationYearTextField.text = grad_year
            })
            
            let pictureRef = storageRef.child("user_photos/" + Auth.auth().currentUser!.uid)
            // Download in memory with a maximum allowed size of 15MB (1 * 1024 * 1024 bytes)
            pictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print(error.localizedDescription)
                } else {
                    self.ProfilePicture.image = UIImage(data: data!)
                }
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        configureDatabase()
        configureStorage()
        FinishSignUpButton.isEnabled = false
        FirstNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        LastNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)

        GenderTextField.delegate = self
        CollegeTextField.delegate = self
        MajorTextField.delegate = self
        ResidenceHallTextField.delegate = self
        GraduationYearTextField.delegate = self
        
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self
        
        GenderTextField.tintColor = UIColor.clear
        CollegeTextField.tintColor = UIColor.clear
        MajorTextField.tintColor = UIColor.clear
        ResidenceHallTextField.tintColor = UIColor.clear
        GraduationYearTextField.tintColor = UIColor.clear

        
        GenderTextField.inputView = pickerView
        CollegeTextField.inputView = pickerView
        MajorTextField.inputView = pickerView
        ResidenceHallTextField.inputView = pickerView
        GraduationYearTextField.inputView = pickerView
        
        ProfilePicture.layer.borderWidth = 1
        ProfilePicture.layer.masksToBounds = false
        ProfilePicture.layer.borderColor = UIColor.black.cgColor
        ProfilePicture.layer.cornerRadius = ProfilePicture.frame.height/2
        ProfilePicture.contentMode = .scaleAspectFill
        ProfilePicture.clipsToBounds = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        self.addRemoveKeyboardGesture()
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        GenderTextField.inputAccessoryView = toolBar
        CollegeTextField.inputAccessoryView = toolBar
        MajorTextField.inputAccessoryView = toolBar
        ResidenceHallTextField.inputAccessoryView = toolBar
        GraduationYearTextField.inputAccessoryView = toolBar

        // Maybe add analogous lines here??
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeDataArray = []
        if textField == GenderTextField {
            activeDataArray = genders
        }
        else if textField == CollegeTextField {
            activeDataArray = colleges
        }
        else if textField == MajorTextField {
            activeDataArray = majors
        }
        else if textField == GraduationYearTextField {
            activeDataArray = graduationYears
        }
        else if textField == ResidenceHallTextField {
            activeDataArray = dorms
        }
        pickerView.reloadAllComponents()
        pickerView.isHidden = false
    }
    
    @objc func donePicker() {
        if activeDataArray == genders {
            GenderTextField.resignFirstResponder()
        }
        else if activeDataArray == colleges {
            CollegeTextField.resignFirstResponder()
        }
        else if activeDataArray == majors {
            MajorTextField.resignFirstResponder()
        }
        else if activeDataArray == graduationYears {
            GraduationYearTextField.resignFirstResponder()
        }
        else if activeDataArray == dorms {
            ResidenceHallTextField.resignFirstResponder()
        }
        editingChanged()
    }
    
    @objc func cancelPicker() {
        if activeDataArray == genders {
            GenderTextField.text = ""
            GenderTextField.resignFirstResponder()
        }
        else if activeDataArray == colleges {
            CollegeTextField.text = ""
            CollegeTextField.resignFirstResponder()
        }
        else if activeDataArray == majors {
            MajorTextField.text = ""
            MajorTextField.resignFirstResponder()
        }
        else if activeDataArray == graduationYears {
            GraduationYearTextField.text = ""
            GraduationYearTextField.resignFirstResponder()
        }
        else if activeDataArray == dorms {
            ResidenceHallTextField.text = ""
            ResidenceHallTextField.resignFirstResponder()
        }
        editingChanged()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activeDataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activeDataArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if activeDataArray == genders {
            GenderTextField.text = activeDataArray[row]
        }
        else if activeDataArray == colleges {
            CollegeTextField.text = activeDataArray[row]
        }
        else if activeDataArray == majors {
            MajorTextField.text = activeDataArray[row]
        }
        else if activeDataArray == graduationYears {
            GraduationYearTextField.text = activeDataArray[row]
        }
        else if activeDataArray == dorms {
            ResidenceHallTextField.text = activeDataArray[row]
        }
        editingChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func editingChanged() {
        guard
            let firstName = FirstNameTextField.text, !firstName.isEmpty,
            let lastName = LastNameTextField.text, !lastName.isEmpty,
            let gender = GenderTextField.text, !gender.isEmpty,
            let major = MajorTextField.text, !major.isEmpty,
            let college = CollegeTextField.text, !college.isEmpty,
            let gradYear = GraduationYearTextField.text, !gradYear.isEmpty,
            let dorm = ResidenceHallTextField.text, !dorm.isEmpty
        else {
            self.FinishSignUpButton.isEnabled = false
            return
        }
        FinishSignUpButton.isEnabled = true
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
    
    @IBAction func selectPicture(_ sender: UITapGestureRecognizer) {
        FirstNameTextField.resignFirstResponder()
        LastNameTextField.resignFirstResponder()
        GenderTextField.resignFirstResponder()
        CollegeTextField.resignFirstResponder()
        MajorTextField.resignFirstResponder()
        ResidenceHallTextField.resignFirstResponder()
        GraduationYearTextField.resignFirstResponder()
        
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
        ProfilePicture.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func saveProfilePicture(photoData: Data) {
        let imagePath = "user_photos/" + Auth.auth().currentUser!.uid
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        // create a child node at imagePath with imageData and metadata
        storageRef!.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            let members: [AnyHashable: Any] = ["photo_url": imagePath]
            self.ref.child("users").child((self.user?.uid)!).updateChildValues(members)
        }
    }
    
    @IBAction func finishSignUp(_ sender: Any) {
        if user != nil {
            self.ref.child("users").child((user?.uid)!).setValue(["firstName": FirstNameTextField.text, "lastName": LastNameTextField.text, "email": user?.email, "gender": GenderTextField.text, "major": MajorTextField.text, "college": CollegeTextField.text, "grad_year": GraduationYearTextField.text, "dorm": ResidenceHallTextField.text])
            
            let Data = UIImageJPEGRepresentation(ProfilePicture.image!, 0.8)
            // Store the image
            saveProfilePicture(photoData: Data!)
            if isEditing {
                navigationController?.popViewController(animated: true)
            }
            else {
                performSegue(withIdentifier: "finishedSigningUp", sender: self)
            }
        }
        else {
            
        }
    }
}

