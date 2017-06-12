//
//  SignUpViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/10/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import SWMessages
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FBSDKLoginKit
import TwitterKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var userName: LinedTextField!
    @IBOutlet weak var email: LinedTextField!
    @IBOutlet weak var password: LinedTextField!
    @IBOutlet weak var buttonBottom: NSLayoutConstraint!
    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.buttonBottom.constant = keyboardSize.height
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.buttonBottom.constant = self.buttonBottom.constant - keyboardSize.height
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func twitterSignUp(_ sender: Any) {
        Twitter.sharedInstance().logIn { (session, error) in
            if (session != nil) {
                let credential = FIRTwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    if (error != nil) {
                        SWMessage.sharedInstance.showNotificationWithTitle("Error", subtitle: error?.localizedDescription, type: .error)
                    }else{
                        self.saveUserToDb(key: FIRAuth.auth()!.currentUser!.uid, name: FIRAuth.auth()!.currentUser!.displayName!, email:FIRAuth.auth()!.currentUser!.email!, image: FIRAuth.auth()!.currentUser!.photoURL!.absoluteString)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else {
                print("error: \(error?.localizedDescription)");
            }
        }
    }

    @IBAction func facebookSignUp(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions:  ["email", "public_profile", "user_friends"], from: self, handler: { (result, error) -> Void in
            if (error == nil){
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    if (error != nil) {
                        SWMessage.sharedInstance.showNotificationWithTitle("Error", subtitle: error?.localizedDescription, type: .error)
                    }else{
                        self.saveUserToDb(key: FIRAuth.auth()!.currentUser!.uid, name: FIRAuth.auth()!.currentUser!.displayName!, email:FIRAuth.auth()!.currentUser!.email!, image: FIRAuth.auth()!.currentUser!.photoURL!.absoluteString)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        })
    }

    @IBAction func signUp(_ sender: Any) {
        if isValidEmail(testStr: self.email.text!) {
            if (self.userName.text?.characters.count)! > 0 {
                if (self.password.text?.characters.count)! > 7 {
                    FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                        if (error != nil) {
                            SWMessage.sharedInstance.showNotificationWithTitle("Error", subtitle: error?.localizedDescription, type: .error)
                        }else{
                            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                            changeRequest?.displayName = self.userName.text
                            changeRequest?.commitChanges() { (error) in
                                print("Completed")
                            }
                            self.saveUserToDb(key: FIRAuth.auth()!.currentUser!.uid, name: self.userName.text!, email: self.email.text!, image: "")
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }else{
                    SWMessage.sharedInstance.showNotificationWithTitle("Password", subtitle: "Your password must be at least 8 characters", type: .error)
                }
            }else{
               SWMessage.sharedInstance.showNotificationWithTitle("Username", subtitle: "You forgot your username!", type: .error)
            }
        }else{
            SWMessage.sharedInstance.showNotificationWithTitle("Invalid email", subtitle: "Looks like your email format is not valid", type: .error)
        }
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func saveUserToDb(key: String, name: String, email: String, image: String)  {
        let user = ["name": name, "email": email, "photoURL": image]
        self.ref.child("Users").child(key).setValue(user)
    }
    
    
}
