//
//  ShareFollowersViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 1/2/17.
//  Copyright © 2017 Vincent Villalta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
class ShareFollowersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var checkOff = UIImage(named: "check_off")
    var checkOn = UIImage(named: "check_on")
    var users = [DataSnapshot]()
    var selectedUsers = [DataSnapshot]()
    var ref: DatabaseReference!
    var currentUserData : [String : AnyObject]!
    var currentUserKey : String!
    var createdEvent : DatabaseReference!
    var eventName: String!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        self.getUsers()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FollowersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FollowersTableViewCell
        let user = self.users[indexPath.row]
        let row = user.value as! [String : AnyObject]
        cell.avatar.sd_setImage(with: URL(string: row["photoURL"] as! String))
        cell.username.text = row["name"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userSelected = self.users[indexPath.row]
        let cell: FollowersTableViewCell = tableView.cellForRow(at: indexPath) as! FollowersTableViewCell
        if self.selectedUsers.contains(userSelected) {
            cell.check.image = checkOff
            let i = self.selectedUsers.index(of: userSelected)
            self.selectedUsers.remove(at: i!)
        }else{
            cell.check.image = checkOn
            self.selectedUsers.append(userSelected)
        }
        
        self.shareButton.setTitle("Share this event with \(self.selectedUsers.count) followers", for: .normal)
    }
    
    
    func getUsers() {
        SVProgressHUD.show()
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            print(snapshot)
            var newItems = [DataSnapshot]()
            for item in snapshot.children {
                let user = item as! DataSnapshot
                if user.key == Auth.auth().currentUser!.uid {
                    self.currentUserData = (item as! DataSnapshot).value as! [String : AnyObject]
                    self.currentUserKey = (item as! DataSnapshot).key
                } else {
                    var followers = 0
                    let individual = user.value as! [String : AnyObject]
                    if let followingArray = individual["following"] as? [String] {
                        if followingArray.contains(Auth.auth().currentUser!.uid) {
                            followers = followers + 1
                            newItems.append(user)
                        }
                    }
                }
            }
            self.users = newItems
            self.tableView.reloadData()
        })
        
    }
    
    @IBAction func shareInvayt(_ sender: Any) {
        SVProgressHUD.show()
        for item in self.selectedUsers {
            pushNotificationToUser(userTo: item, content: "<b>\(Auth.auth().currentUser!.displayName!)</b> has invited you to attend the event <b>\(self.eventName)</b>")
            let invayt = [
                "key": self.createdEvent.key,
                "timestamp": "\(Date().timeIntervalSince1970)",
                "userFrom": "\(Auth.auth().currentUser!.uid)",
                "userTo": item.key
            ]
            self.ref.child("invayts").childByAutoId().setValue(invayt, withCompletionBlock: { (error, ref) in
                SVProgressHUD.showSuccess(withStatus: "Event shared with \(self.selectedUsers.count) followers")
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
}


class FollowersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var check: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
        self.avatar.clipsToBounds = true
    }

    
}
