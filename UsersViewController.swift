//
//  UsersViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 12/29/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseDatabase
import SDWebImage

class UsersViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    var items = [DataSnapshot]()
    var currentUserData : [String : AnyObject]!
    var currentUserKey : String!
    var fbEvent: DataSnapshot!
    var isShowingFollowers = false
    var isShowingFollowing = false
    var isShowingParticipantList = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        
        if !isShowingFollowers && !isShowingFollowing && !isShowingParticipantList {
            self.getUsers()
        }
        else if isShowingFollowing {
            getUsersWhoImFollowing()
        }else if isShowingFollowers {
            getUsersWhoAreFollowingMe()
        } else if isShowingParticipantList {
            getUsersForEventList()
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UsersListCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UsersListCell
        let user = self.items[indexPath.row]
        let row = user.value as! [String : AnyObject]
        cell.avatar.sd_setImage(with: URL(string: row["photoURL"] as! String))
        cell.user.text = row["name"] as? String
        cell.followBtn.tag = indexPath.row
        if currentUserData["following"] != nil {
            let followings = currentUserData["following"] as! [String]
            if followings.contains(user.key) {
                cell.followBtn.setTitle("Unfollow", for: .normal)
            }
        }
        cell.followBtn.addTarget(self, action: #selector(self.followUnfollow(_:)), for: .touchUpInside)
        return cell
    }
    
    func getUsersWhoImFollowing() {
        SVProgressHUD.show()
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            print(snapshot)
            var newItems = [DataSnapshot]()
            for item in snapshot.children {
                let user = item as! DataSnapshot
                if user.key != Auth.auth().currentUser!.uid {
                    if let followingArray = self.currentUserData["following"] as? NSMutableArray {
                        if followingArray.contains(user.key) {
                            newItems.append(user)
                        }
                    }
                }else{
                    self.currentUserData = (item as! DataSnapshot).value as! [String : AnyObject]
                    self.currentUserKey = (item as! DataSnapshot).key
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        
    }
    
    func getUsersWhoAreFollowingMe() {
        SVProgressHUD.show()
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            print(snapshot)
            var newItems = [DataSnapshot]()
            for item in snapshot.children {
                let user = item as! DataSnapshot
                if user.key != Auth.auth().currentUser!.uid {
                    let individual = user.value as! [String : AnyObject]
                    if let followingArray = individual["following"] as? [String] {
                        if followingArray.contains(Auth.auth().currentUser!.uid) {
                            newItems.append(user)
                        }
                    }
                }else{
                    self.currentUserData = (item as! DataSnapshot).value as! [String : AnyObject]
                    self.currentUserKey = (item as! DataSnapshot).key
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    
    func getUsers() {
        SVProgressHUD.show()
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            print(snapshot)
            var newItems = [DataSnapshot]()
            for item in snapshot.children {
                let user = item as! DataSnapshot
                if user.key != Auth.auth().currentUser!.uid {
                    newItems.append(item as! DataSnapshot)
                }else{
                    self.currentUserData = (item as! DataSnapshot).value as! [String : AnyObject]
                    self.currentUserKey = (item as! DataSnapshot).key
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        
    }
    
    func getUsersForEventList() {
        SVProgressHUD.show()
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            print(snapshot)
            var newItems = [DataSnapshot]()
            for item in snapshot.children {
                let user = item as! DataSnapshot
                if user.key != Auth.auth().currentUser!.uid {
                    var event = self.fbEvent.value as! [String : AnyObject]
                    if let att = event["attendees"] as? [String] {
                        if att.contains(user.key) {
                            newItems.append(item as! DataSnapshot)
                        }
                    }
                }else{
                    self.currentUserData = (item as! DataSnapshot).value as! [String : AnyObject]
                    self.currentUserKey = (item as! DataSnapshot).key
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        
    }
    
    func followUnfollow(_ sender: UIButton) {
        let user = self.items[sender.tag]
        if sender.titleLabel?.text == "Follow" {
            print("Follow action")
            sender.setTitle("Unfollow", for: .normal)
            self.followUser(userToFollow: user)
        }else{
            print("Unfollow action")
            sender.setTitle("Follow", for: .normal)
            self.unfollowUser(userToFollow: user)
        }
        print(sender.tag)
    }
    
    func followUser(userToFollow: DataSnapshot) {
        if let following = self.currentUserData["following"] as? NSMutableArray {
            following.add(userToFollow.key)
            let childUpdates = ["/Users/\(self.currentUserKey!)/following": following]
            ref.updateChildValues(childUpdates)
        } else {
            let following : NSMutableArray = []
            following.add(userToFollow.key)
            let childUpdates = ["/Users/\(self.currentUserKey!)/following": following]
            ref.updateChildValues(childUpdates)
        }
        
        pushNotificationToUser(userTo: userToFollow, content: "<b>\(Auth.auth().currentUser!.displayName!)</b> is now following you")
        
        
    }

    
    func unfollowUser(userToFollow: DataSnapshot) {
        if let following = self.currentUserData["following"] as? NSMutableArray {
            following.remove(userToFollow.key)
            let childUpdates = ["/Users/\(self.currentUserKey!)/following": following]
            ref.updateChildValues(childUpdates)
        }
    }
    
    
}

class UsersListCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
        self.avatar.clipsToBounds = true
    }
    
}
