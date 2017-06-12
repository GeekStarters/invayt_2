//
//  DiscoverViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/11/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import SWSegmentedControl
import SwiftRandom
import SVProgressHUD
import Firebase
import FirebaseDatabase
import SDWebImage

class DiscoverViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var segmentedContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var ref: FIRDatabaseReference!
    var items = [FIRDataSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        let sc = SWSegmentedControl(items: ["Local Events", "All Events"])
        sc.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.segmentedContainer.frame.size.height)
        sc.tintColor = UIColor.white
        self.segmentedContainer.addSubview(sc)
        self.getEvents()
        self.title = "Discover"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell
        let event = self.items[indexPath.row]
        let row = event.value as! [String : AnyObject]
        cell.eventName.text = row["name"] as? String
        getUsers(eventToConsult: event, label: cell.attendees)
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        if row["timestamp"] != nil {
            cell.eventTime.text = df.string(from: NSDate(timeIntervalSince1970: (row["timestamp"] as! Double)) as Date)
        } else {
            cell.eventTime.text = ""
        }
        cell.eventLocation.text = row["locationLocalizable"] as? String
        if row["image"] != nil{
            cell.evetnImage.sd_setImage(with: URL(string: row["image"] as! String))
        } else {
            cell.evetnImage.image = UIImage(named: "invayts_on")
        }
        cell.eventOrganizer.text = "By \(row["authorName"]!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsViewController") as! EventDetailsViewController
        let event = self.items[indexPath.row]
//        vc.event = event.value as! [String : AnyObject]
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
                    if !att.contains((FIRAuth.auth()?.currentUser!.uid)!) && (event["timestamp"] as! Double > Date().timeIntervalSince1970){
                        newItems.append(item as! FIRDataSnapshot)
                    }
                    
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    
    
    func getUsers(eventToConsult: FIRDataSnapshot, label: UILabel){
        var event: [String : AnyObject]!
        event = eventToConsult.value as! [String : AnyObject]
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            for item in snapshot.children {
                let user = item as! FIRDataSnapshot
                if user.key == FIRAuth.auth()?.currentUser!.uid {
                    let currentUser = user.value as! [String : AnyObject]
                    if let att = event["attendees"] as? [String] {
                        var followingAttending = 0
                        var attendeeName = ""
                        if let followingArray = currentUser["following"] as? [String] {
                            for following in followingArray {
                                if att.contains(following) {
                                    followingAttending = followingAttending + 1
                                    
                                }
                            }
                        }
                        print("\(followingAttending) people you are following are going")
                        label.text = "\(followingAttending) people you are following are going"
                        
                    }
                }
            }
        })
    }
}
