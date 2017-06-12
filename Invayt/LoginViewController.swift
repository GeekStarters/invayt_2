//
//  LoginViewController.swift
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

class LoginViewController: UIViewController {
    @IBOutlet weak var email: LinedTextField!
    @IBOutlet weak var password: LinedTextField!
    @IBOutlet weak var buttonBottom: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
/*        let logInButton = TWTRLogInButton { (session, error) in
 if let unwrappedSession = session {
 let alert = UIAlertController(title: "Logged In",
 message: "User \(unwrappedSession.userName) has logged in",
 preferredStyle: UIAlertControllerStyle.alert
 )
 alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
 self.present(alert, animated: true, completion: nil)
 } else {
 NSLog("Login error: %@", error!.localizedDescription);
 }
 }
 
 // TODO: Change where the log in button is positioned in your view
 if let button = logInButton {
 button.center = self.view.center
 self.view.addSubview(button)
 }
*/
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func twitterSignUp(_ sender: Any) {
        Twitter.sharedInstance().logIn { (session, error) in
            if (session != nil) {
                let credential = FIRTwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    if (error != nil) {
                        SWMessage.sharedInstance.showNotificationWithTitle("Error", subtitle: error?.localizedDescription, type: .error)
                    }else{
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
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        })
    }
    
    @IBAction func signUp(_ sender: Any) {
        if isValidEmail(testStr: self.email.text!) {
            if (self.password.text?.characters.count)! > 7 {
                FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                    if (error != nil) {
                        SWMessage.sharedInstance.showNotificationWithTitle("Error", subtitle: error?.localizedDescription, type: .error)
                    }else{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else{
                SWMessage.sharedInstance.showNotificationWithTitle("Password", subtitle: "Your password must be at least 8 characters", type: .error)
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
}
