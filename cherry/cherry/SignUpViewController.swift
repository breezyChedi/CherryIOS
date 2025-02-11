//
//  SignUpViewController.swift
//  cherry
//
//  Created by Tyrone Kasi on 2025/01/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var schoolField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var emailField: UITextField!

    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var confirmPwdField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    let genderOptions = ["Male", "Female"]
    let countries = [
        "South Africa", "United States", "United Kingdom", "Canada", "Australia", "India", "China", "Japan"
    ]
    
    let genderPicker = UIPickerView()
    let nationalityPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        nationalityPicker.delegate = self
        nationalityPicker.dataSource = self
        
        genderField.inputView = genderPicker
        countryField.inputView = nationalityPicker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == genderPicker ? genderOptions.count : countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == genderPicker ? genderOptions[row] : countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPicker {
            genderField.text = genderOptions[row]
        } else {
            countryField.text = countries[row]
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty,
              
              let password = pwdField.text, !password.isEmpty,
              let confirmPassword = confirmPwdField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }
        
        
        
        if password != confirmPassword {
            showAlert(message: "Passwords do not match.")
            return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(message: "Sign up failed: \(error.localizedDescription)")
                return
            }
            
            guard let userId = authResult?.user.uid else { return }
            
            
            let db = Firestore.firestore()
            
            let userData: [String: Any] = [
                        "name": self?.nameField.text ?? "",
                        "surname": self?.surnameField.text ?? "",
                        "gender": self?.genderField.text ?? "",
                        "highSchool": self?.schoolField.text ?? "",
                        "phoneNumber": self?.phoneField.text ?? "",
                        "nationality": self?.countryField.text ?? "",
                        "email": email,
                        "createdAt": Timestamp()
                    ]
            
            db.collection("users").document(userId).setData(userData) { error in
                        if let error = error {
                            self?.showAlert(message: "Failed to save user data: \(error.localizedDescription)")
                        } else {
                            self?.navigateToProfileDetails()
                        }
                    
            }
        }
    }
    
    private func navigateToProfileDetails() {
        guard let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as? ProfileDetailsViewController else {
            showAlert(message: "ProfileDetailsViewController not found.")
            return
        }
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

