//
//  MyCalendarViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/11/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseDatabase
import SDWebImage
class MyCalendarViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    var items = [DataSnapshot]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        self.getEvents()
        self.title = "My Calendar"
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
        cell.eventTime.text = df.string(from: NSDate(timeIntervalSince1970: (row["timestamp"] as! Double)) as Date)
        cell.eventLocation.text = row["locationLocalizable"] as? String
        cell.evetnImage.sd_setImage(with: URL(string: row["image"] as! String))
        cell.eventOrganizer.text = "By \(row["authorName"]!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chat.fbEvent = self.items[indexPath.row]
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    func getEvents() {
        SVProgressHUD.show()
        self.ref.child("events").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            var newItems = [DataSnapshot]()
            for item in snapshot.children {
                let event = (item as! DataSnapshot).value as! [String : AnyObject]
                if let att = event["attendees"] as? [String] {
                    if att.contains(Auth.auth().currentUser!.uid){
                        newItems.append(item as! DataSnapshot)
                    }

                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    
    func getUsers(eventToConsult: DataSnapshot, label: UILabel){
        var event: [String : AnyObject]!
        event = eventToConsult.value as! [String : AnyObject]
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            for item in snapshot.children {
                let user = item as! DataSnapshot
                if user.key == Auth.auth().currentUser!.uid {
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
