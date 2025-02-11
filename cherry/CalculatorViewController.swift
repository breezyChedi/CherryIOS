//
//  CalculatorViewController.swift
//  cherry
//
//  Created by Tyrone Kasi on 2025/01/27.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore

class CalculatorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var circularProgressView: CircularProgressView!
    
    @IBOutlet weak var subj1Field: UITextField!
    
    @IBOutlet weak var perc1Field: UITextField!
    
    @IBOutlet weak var subj2Field: UITextField!
    
    @IBOutlet weak var perc2Field: UITextField!
    
    @IBOutlet weak var subj3Field: UITextField!
    
    
    @IBOutlet weak var perc3Field: UITextField!
    
    @IBOutlet weak var subj4Field: UITextField!
    
    @IBOutlet weak var perc4Field: UITextField!
    @IBOutlet weak var subj5Field: UITextField!
    @IBOutlet weak var perc5Field: UITextField!
    
    @IBOutlet weak var subj6Field: UITextField!
    @IBOutlet weak var perc6Field: UITextField!
    
    @IBOutlet weak var subj7Field: UITextField!
    // Picker data
    @IBOutlet weak var perc7Field: UITextField!
    
    @IBOutlet weak var nbtAlField: UITextField!
    
    @IBOutlet weak var nbtQlField: UITextField!
    
    
    @IBOutlet weak var nbtMatField: UITextField!
    let mathOptions = ["Mathematics", "Mathematical Literacy"]
    let languages = ["English HL", "Afrikaans HL", "isiZulu HL"]
    let additionalLanguages = [
        "Sesotho FAL", "Isizulu FAL", "Afrikaans FAL",
        "Sepedi FAL", "English FAL", "Xitsonga FAL",
        "Setswana FAL", "TshiVenda FAL"
    ]
    let allSubjects = [
        "Physical Science", "History", "Geography",
        "Art", "Economics", "Biology",
        "Information Technology", "Computing and Technology",
        "Dramatic Arts"
    ]
    let lifeOrientation = ["Life Orientation"]

    // Current selected values for pickers 4, 5, 6
   
    var subjectTextFields: [UITextField] = []
    var percentageTextFields: [UITextField] = []
    var pickers: [UIPickerView] = []
    
    var firstSixFields: [UITextField] = []
    
    // Current selected values for subj4, subj5, subj6
    var selectedSubject4: String?
    var selectedSubject5: String?
    var selectedSubject6: String?
    
    // Dynamic options for pickers 4, 5, 6
    var options4: [String] = []
    var options5: [String] = []
    var options6: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circularProgressView.setTrackColor = UIColor.purple
        circularProgressView.setProgressColor = UIColor.systemPink
               
               // Start animation (Example: 75% progress in 2 seconds)
               circularProgressView.setProgressWithAnimation(duration: 2.0, value: 0.75)
        
       
        
        // Store TextFields in Arrays for Easier Management
        subjectTextFields = [subj1Field, subj2Field, subj3Field, subj4Field, subj5Field, subj6Field, subj7Field]
        percentageTextFields = [perc1Field, perc2Field, perc3Field, perc4Field, perc5Field, perc6Field, perc7Field]
        
        firstSixFields = Array(percentageTextFields[0..<6])

        
        // Initialize pickers and set them as input views
        for textField in subjectTextFields {
            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            textField.inputView = picker
            pickers.append(picker)
        }
        
        // Configure Numeric Inputs
        for textField in percentageTextFields {
            configureNumberInput(for: textField)
        }
        
        // Initialize options for pickers 4, 5, 6
        options4 = allSubjects
        options5 = allSubjects
        options6 = allSubjects
    }
    @IBAction func saveToProfBtn(_ sender: Any) {
        // First check if user is authenticated
        guard let currentUser = FirebaseAuth.Auth.auth().currentUser else {
            // User is not authenticated, navigate to SignIn screen
            navigateToSignIn()
            return
        }
        
        // Get the user ID
        let userId = currentUser.uid
        
        // Create dictionary of subjects and marks
        let subjects: [String: String] = [
            "subject1": subj1Field.text ?? "",
            "subject2": subj2Field.text ?? "",
            "subject3": subj3Field.text ?? "",
            "subject4": subj4Field.text ?? "",
            "subject5": subj5Field.text ?? "",
            "subject6": subj6Field.text ?? "",
            "subject7": subj7Field.text ?? ""
        ]
        
        let marks: [String: String] = [
            "mark1": perc1Field.text ?? "0",
            "mark2": perc2Field.text ?? "0",
            "mark3": perc3Field.text ?? "0",
            "mark4": perc4Field.text ?? "0",
            "mark5": perc5Field.text ?? "0",
            "mark6": perc6Field.text ?? "0",
            "mark7": perc7Field.text ?? "0"
        ]
        
        // Calculate APS Score
        var totalScore = 0
        func getPointsForMark(_ mark: Int) -> Int {
            if mark >= 80 { return 7 }
            else if mark >= 70 { return 6 }
            else if mark >= 60 { return 5 }
            else if mark >= 50 { return 4 }
            else if mark >= 40 { return 3 }
            else if mark >= 30 { return 2 }
            else { return 0 }
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        for textField in firstSixFields {
            if let text = textField.text, !text.isEmpty {
                let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if let number = formatter.number(from: trimmedText)?.intValue {
                    totalScore += getPointsForMark(number)
                }
            }
        }
        
        // Create profile data
        let profileData: [String: Any] = [
            "subjects": subjects,
            "marks": marks,
            "apsScore": totalScore,
            "nbtAL": nbtAlField.text ?? "",
            "nbtQL": nbtQlField.text ?? "",
            "nbtMat": nbtMatField.text ?? "",
            "updatedAt": Timestamp()
        ]
        
        // Save to Firestore
        let db = Firestore.firestore()
        db.collection("profiles").document(userId).setData(profileData) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Failed to save profile: \(error.localizedDescription)")
            } else {
                self?.showAlert(message: "Profile saved successfully!")
            }
        }
    }

    private func navigateToSignIn() {
        guard let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController else {
            showAlert(message: "Could not find SignInViewController")
            return
        }
        navigationController?.pushViewController(signInVC, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func calculateAPSBtn(_ sender: Any) {
        var totalScore = 0

            // Function to get APS points based on percentage
            func getPointsForMark(_ mark: Int) -> Int {
                if mark >= 80 { return 7 }
                else if mark >= 70 { return 6 }
                else if mark >= 60 { return 5 }
                else if mark >= 50 { return 4 }
                else if mark >= 40 { return 3 }
                else if mark >= 30 { return 2 }
                else { return 0 }
            }

            // Ensure percentageTextFields is not empty
            if percentageTextFields.isEmpty {
                print("Percentage text fields not initialized")
                return
            }

            // Loop through percentage fields and calculate APS points
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        for textField in firstSixFields {
            if let text = textField.text, !text.isEmpty {
                let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if let number = formatter.number(from: trimmedText)?.intValue {
                    totalScore += getPointsForMark(number)
                }
            }
        }




            // Normalize score to progress (out of 42)
            let progressValue = Float(totalScore) / 42.0

            // Apply the calculated APS score to the circular progress view
            circularProgressView.setProgressWithAnimation(duration: 1.5, value: CGFloat(progressValue))

        
    }
    // Configure Numeric Input for Percentage
    func configureNumberInput(for textField: UITextField) {
        textField.keyboardType = .numberPad
        textField.placeholder = "Enter %"
        textField.delegate = self
    }
    
    // MARK: - UIPickerView Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case pickers[0]: return mathOptions.count
        case pickers[1]: return languages.count
        case pickers[2]: return additionalLanguages.count
        case pickers[3]: return options4.count
        case pickers[4]: return options5.count
        case pickers[5]: return options6.count
        case pickers[6]: return lifeOrientation.count
        default: return 0
        }
    }
    
    // MARK: - UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case pickers[0]: return mathOptions[row]
        case pickers[1]: return languages[row]
        case pickers[2]: return additionalLanguages[row]
        case pickers[3]: return options4[row]
        case pickers[4]: return options5[row]
        case pickers[5]: return options6[row]
        case pickers[6]: return lifeOrientation[row]
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case pickers[0]:
            subj1Field.text = mathOptions[row]
            subj1Field.resignFirstResponder()
        case pickers[1]:
            subj2Field.text = languages[row]
            subj2Field.resignFirstResponder()
        case pickers[2]:
            subj3Field.text = additionalLanguages[row]
            subj3Field.resignFirstResponder()
        case pickers[3]:
            selectedSubject4 = options4[row]
            subj4Field.text = selectedSubject4
            subj4Field.resignFirstResponder()
        case pickers[4]:
            selectedSubject5 = options5[row]
            subj5Field.text = selectedSubject5
            subj5Field.resignFirstResponder()
        case pickers[5]:
            selectedSubject6 = options6[row]
            subj6Field.text = selectedSubject6
            subj6Field.resignFirstResponder()
        case pickers[6]:
            subj7Field.text = lifeOrientation[row]
            subj7Field.resignFirstResponder() 
        default:
            return
        }
        
        // Update options dynamically
        updateDynamicPickerOptions()
    }
    
    // Update dynamic options for subj4, subj5, subj6
    private func updateDynamicPickerOptions() {
        options4 = allSubjects.filter { subject in
            subject == selectedSubject4 || (subject != selectedSubject5 && subject != selectedSubject6)
        }
        options5 = allSubjects.filter { subject in
            subject == selectedSubject5 || (subject != selectedSubject4 && subject != selectedSubject6)
        }
        options6 = allSubjects.filter { subject in
            subject == selectedSubject6 || (subject != selectedSubject4 && subject != selectedSubject5)
        }
        
        // Reload pickers 4, 5, 6
        pickers[3].reloadAllComponents()
        pickers[4].reloadAllComponents()
        pickers[5].reloadAllComponents()
    }
}
