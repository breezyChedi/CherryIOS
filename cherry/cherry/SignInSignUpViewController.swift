//
//  SignInSignUpViewController.swift
//  cherry
//
//  Created by Tyrone Kasi on 2025/01/22.
//

import UIKit

class SignInSignUpViewController: UIViewController {

    @IBOutlet weak var cherryCirc: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cherryCirc.image = UIImage(named: "cherryCircle")
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
