//
//  MeViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 12/2/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import LUNSegmentedControl
import SVProgressHUD
import Firebase
import FirebaseDatabase
import SDWebImage
import Photos

class MeViewController: BaseViewController, LUNSegmentedControlDelegate, LUNSegmentedControlDataSource, UITableViewDataSource, UITableViewDelegate {

    
    var ref: FIRDatabaseReference!
    var items = [FIRDataSnapshot]()
    var myInvayts = [FIRDataSnapshot]()
    var eventsByMe = [FIRDataSnapshot]()
    var image: UIImage!
    let dbRef = "https://invayt-3d279.firebaseio.com/"
    let storageRef = "gs://invayt-3d279.appspot.com"
    let storage = FIRStorage.storage()
    var currentUserData : [String : AnyObject]!
    var currentUserKey : String!
    
    var followersArray = [FIRDataSnapshot]()
    var followingsArray = [FIRDataSnapshot]()
    
    @IBOutlet weak var segmentedContainer: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var segmentedControl: LUNSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        self.getEvents()
        self.getEventsByMe()
        self.name.text = FIRAuth.auth()?.currentUser!.displayName
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
        self.avatar.clipsToBounds = true
        self.avatar.sd_setImage(with: FIRAuth.auth()!.currentUser!.photoURL)
        self.getUsers()
        self.title = "Me"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfStates(in segmentedControl: LUNSegmentedControl!) -> Int {
        return 2
    }
    
    func segmentedControl(_ segmentedControl: LUNSegmentedControl!, titleForStateAt index: Int) -> String! {
        if index == 0 {
            return "All my events"
        }else{
            return "My Invayts"
        }
    }
    
    func segmentedControl(_ segmentedControl: LUNSegmentedControl!, didChangeStateFromStateAt fromIndex: Int, toStateAt toIndex: Int) {
        if toIndex == 1 {
            self.items = self.eventsByMe
            self.tableView.reloadData()
        }else{
            self.items = self.myInvayts
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell
        let event = self.items[indexPath.row]
        let row = event.value as! [String : AnyObject]
        cell.eventName.text = row["name"] as? String
        
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        cell.eventTime.text = df.string(from: NSDate(timeIntervalSince1970: (row["timestamp"] as! Double)) as Date)
        cell.eventLocation.text = row["locationLocalizable"] as? String
        cell.evetnImage.sd_setImage(with: URL(string: row["image"] as! String))
        cell.eventOrganizer.text = "By \(row["authorName"]!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsViewController") as! EventDetailsViewController
        let event = self.items[indexPath.row]
        vc.event = event.value as! [String : AnyObject]
        vc.fbEvent = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getEvents() {
        SVProgressHUD.show()
        self.ref.child("events").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            var newItems = [FIRDataSnapshot]()
            for item in snapshot.children {
                let event = (item as! FIRDataSnapshot).value as! [String : AnyObject]
                if let att = event["attendees"] as? [String] {
                    if att.contains((FIRAuth.auth()?.currentUser!.uid)!) {
                        newItems.append(item as! FIRDataSnapshot)
                    }
                    
                }
            }
            
            self.eventsByMe = newItems
            self.tableView.reloadData()
        })
        
    }
    
    func getEventsByMe() {
        SVProgressHUD.show()
        self.ref.child("events").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            var newItems = [FIRDataSnapshot]()
            for item in snapshot.children {
                let event = (item as! FIRDataSnapshot).value as! [String : AnyObject]
                if let att = event["author"] as? [String] {
                    if att.contains((FIRAuth.auth()?.currentUser!.uid)!) {
                        newItems.append(item as! FIRDataSnapshot)
                    }
                    
                }
            }
            self.items = newItems
            self.myInvayts = newItems
            self.tableView.reloadData()
        })
    }
    
    
    func getUsers() {
        SVProgressHUD.show()
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            print(snapshot)
            var newItems = [FIRDataSnapshot]()
            for item in snapshot.children {
                let user = item as! FIRDataSnapshot
                if user.key == FIRAuth.auth()?.currentUser!.uid {
                    self.currentUserData = (item as! FIRDataSnapshot).value as! [String : AnyObject]
                    self.currentUserKey = (item as! FIRDataSnapshot).key
                    if let followingArray = self.currentUserData["following"] as? NSMutableArray {
                        self.following.setTitle("\(followingArray.count) Following", for: .normal)
                    } else {
                        self.following.setTitle("0 Following", for: .normal)
                    }
                } else {
                    var followers = 0
                    let individual = user.value as! [String : AnyObject]
                    if let followingArray = individual["following"] as? [String] {
                        if followingArray.contains(FIRAuth.auth()!.currentUser!.uid) {
                            followers = followers + 1
                            self.followersArray.append(user)
                        }
                    }
                    self.followers.setTitle("\(followers) Followers", for: .normal)
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        
    }

    @IBAction func showFollowing(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
        vc.isShowingFollowing = true
        vc.currentUserData = self.currentUserData
        vc.currentUserKey = self.currentUserKey
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    
    @IBAction func showFollowers(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
        vc.isShowingFollowers = true
        vc.currentUserData = self.currentUserData
        vc.currentUserKey = self.currentUserKey
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func settings(_ sender: Any) {
    }

}
