//
//  SettingsViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 12/28/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

import FirebaseDatabase
class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var options = ["Invite", "Follow", "Account", "Settings", "Feedback", "Terms"]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func donw(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            try! FIRAuth.auth()!.signOut()
            SVProgressHUD.dismiss()
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateViewController(withIdentifier: "start") as! UINavigationController
                self.present(vc, animated: false, completion: nil)
            }
        }
    }

}
