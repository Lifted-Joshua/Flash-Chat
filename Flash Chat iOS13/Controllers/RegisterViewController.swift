//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessageLabel.lineBreakMode = .byWordWrapping
        errorMessageLabel.numberOfLines = 0
    }
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let errorMessage = e.localizedDescription
                    self.errorMessageLabel.text = errorMessage
                    print(e.localizedDescription)//This displays the error to the user, in their current language
                } else {
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)//self means this class
                }
            }
        }
        
    }
    
}
