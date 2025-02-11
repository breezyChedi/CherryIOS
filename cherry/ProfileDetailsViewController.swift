//
//  ProfileDetailsViewController.swift
//  cherry
//
//  Created by Tyrone Kasi on 2025/01/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileDetailsViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var subject1Label: UILabel!
    @IBOutlet weak var subject2Label: UILabel!
    @IBOutlet weak var subject3Label: UILabel!
    @IBOutlet weak var subject4Label: UILabel!
    @IBOutlet weak var subject5Label: UILabel!
    @IBOutlet weak var subject6Label: UILabel!
    
    
    @IBOutlet weak var apsLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    
    @IBOutlet weak var nationalityLabel: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        fetchUserData()
        fetchProfileData()*/
        fetchUserAndProfileData()
        // Do any additional setup after loading the view.
    }
    /*
    private func fetchProfileData() {
        let dt = ""
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            print("No user signed in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("profiles").document(uid).getDocument { document, error in if let error = error {
            print("failed to fetch")
            return
        }
            guard let data = document?.data() else {
            print("No user data found")
            return
        }
            let dt = data
            print("Data: ", dt)
            
        }
        
    }*/
    
    private func fetchUserAndProfileData() {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            print("No user is signed in.")
            return
        }

        let db = Firestore.firestore()
        
        db.collection("profiles").document(uid).getDocument { profileDocument, profileError in
                if let profileError = profileError {
                    print("Failed to fetch profile data: \(profileError.localizedDescription)")
                    return
                }
                
                guard let profileData = profileDocument?.data() else {
                    print("No profile data found.")
                    return
                }
                
                print("Fetched Profile Data: \(profileData)")
                
                guard let marks = profileData["marks"] as? [String: String] else {
                    print("Error: Could not extract marks")
                    return
                }
                
                guard let subjects = profileData["subjects"] as? [String: String] else {
                    print("Error: Could not extract subjects")
                    return
                }
                
                guard let apsScore = profileData["apsScore"] as? Int else {
                    print("Error: Could not extract apsScore")
                    return
                }
                
                DispatchQueue.main.async {
                    print("Updating UI with profile data")
                    self.subject1Label.text = "\(subjects["subject1"] ?? "N/A") - \(marks["mark1"] ?? "0")%"
                    self.subject2Label.text = "\(subjects["subject2"] ?? "N/A") - \(marks["mark2"] ?? "0")%"
                    self.subject3Label.text = "\(subjects["subject3"] ?? "N/A") - \(marks["mark3"] ?? "0")%"
                    self.subject4Label.text = "\(subjects["subject4"] ?? "N/A") - \(marks["mark4"] ?? "0")%"
                    self.subject5Label.text = "\(subjects["subject5"] ?? "N/A") - \(marks["mark5"] ?? "0")%"
                    self.subject6Label.text = "\(subjects["subject6"] ?? "N/A") - \(marks["mark6"] ?? "0")%"

                    self.scoreLabel.text = "\(apsScore)"
                }
            }
        
        // Fetch user data
        db.collection("users").document(uid).getDocument { userDocument, userError in
            if let userError = userError {
                print("Failed to fetch user data: \(userError.localizedDescription)")
            } else if let userData = userDocument?.data() {
                let name = userData["name"] as? String ?? "No name available"
                let school = userData["highSchool"] as? String ?? "Not selected"
                let nation = userData["nationality"] as? String ?? "Not selected"

                DispatchQueue.main.async {
                    print("updating UI with user data")
                    self.nameLabel.text = "Welcome, \(name)"
                    self.schoolLabel.text = school
                    self.nationalityLabel.text = nation
                }
            } else {
                print("No user data found.")
            }
        }

        // Fetch profile data
   
    }

    
    private func fetchProfileData() {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            print("No user signed in")
            return
        }

        let db = Firestore.firestore()
        db.collection("profiles").document(uid).getDocument { document, error in
            if let error = error {
                print("Failed to fetch: \(error.localizedDescription)")
                return
            }

            guard let data = document?.data() else {
                print("No user data found")
                return
            }

            print("Fetched Data: \(data)")

            if let marks = data["marks"] as? [String: Int],
               let subjects = data["subjects"] as? [String: String],
                
                //??
               let apsScore = data["apsScore"] as? Int {
                
                print("\nSubjects: \(subjects)")

                DispatchQueue.main.async {
                    self.subject1Label.text = "\(subjects["subject1"] ?? "N/A") - \(marks["mark1"] ?? 0)%"
                    self.subject2Label.text = "\(subjects["subject2"] ?? "N/A") - \(marks["mark2"] ?? 0)%"
                    self.subject3Label.text = "\(subjects["subject3"] ?? "N/A") - \(marks["mark3"] ?? 0)%"
                    self.subject4Label.text = "\(subjects["subject4"] ?? "N/A") - \(marks["mark4"] ?? 0)%"
                    self.subject5Label.text = "\(subjects["subject5"] ?? "N/A") - \(marks["mark5"] ?? 0)%"
                    self.subject6Label.text = "\(subjects["subject6"] ?? "N/A") - \(marks["mark6"] ?? 0)%"

                    self.scoreLabel.text = "APS Score: \(apsScore)"
                }
            }
        }
    }


    
    
    private func fetchUserData() {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            print("No user is signed in.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
                return
            }

            guard let data = document?.data() else {
                print("No user data found.")
                return
            }

            // Access user data
            let name = data["name"] as? String ?? "No name available"
            let school = data["highSchool"] as? String ?? "Not selected"
            let nation = data["nationality"] as? String ?? "Not selected"

            // Update the label on the main thread
            DispatchQueue.main.async {
                self.nameLabel.text = "Welcome, \(name)"
                self.schoolLabel.text=school
                self.nationalityLabel.text=nation
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
