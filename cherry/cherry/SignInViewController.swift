//
//  SignInViewController.swift
//  cherry
//
//  Created by Tyrone Kasi on 2025/01/22.
//

import UIKit
import Firebase
import FirebaseAuth
class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var emalInp: UITextField!
    
    @IBOutlet weak var pwdInp: UITextField!
    
    
    @IBOutlet weak var signInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signInTapped(_ sender: Any) {
        
        guard let email = emalInp.text, !email.isEmpty,
                     let password = pwdInp.text, !password.isEmpty else {
                   showAlert(message: "Please enter both email and password.")
                   return
               }

               FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                   if let error = error {
                       self?.showAlert(message: "Sign in failed: \(error.localizedDescription)")
                       return
                   }
                   
                   if let navController = self?.navigationController {
                           print("Navigation Controller exists: \(navController)")
                       } else {
                           print("Navigation Controller is nil.")
                       }

                   // Navigate to the next screen or update UI upon successful sign-in
                   //self?.showAlert(message: "Sign in successful!")
                   self?.navigateToProfileDetails()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
