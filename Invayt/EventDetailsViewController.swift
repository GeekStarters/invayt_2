//
//  EventDetailsViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/18/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseDatabase
import PassKit
import Alamofire
import SVProgressHUD
class EventDetailsViewController: UIViewController, PKAddPassesViewControllerDelegate {

    var fbEvent: DataSnapshot!
    var updatedEvent: DataSnapshot!
    var event: [String : AnyObject]!
    var ref: DatabaseReference!
    var followingAttending = 0
    @IBOutlet weak var bigImage: UIImageView!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var hostedBy: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var peopleGoingLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.event = fbEvent.value as! [String : AnyObject]
        ref = Database.database().reference()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        self.populateData()
        //self.getEventData()
        self.getUsers()
        
    }
    
    func populateData(){
        let date = NSDate(timeIntervalSince1970: (self.event["timestamp"] as! Double)) as Date
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        self.time.text = df.string(from: date)
        
        let df2 = DateFormatter()
        df2.dateFormat = "dd"
        self.day.text = df2.string(from: date)
        
        let df3 = DateFormatter()
        df3.dateFormat = "MMM"
        self.month.text = df3.string(from: date).uppercased()
        
        self.bigImage.sd_setImage(with: URL(string:self.event["image"] as! String), completed: { (image, error, cacheType, imageURL) -> Void in
            let button : UIButton = UIButton(type: .custom)
            button.setImage(image, for: UIControlState.normal)
            button.addTarget(self, action: #selector(self.fbButtonPressed(button:)), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.layer.cornerRadius = 15
            button.clipsToBounds = true
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
        })
        self.hostedBy.text = "Hosted by \(self.event["authorName"]!)"
        self.title = self.event["name"] as? String
        self.address.text = self.event["locationLocalizable"] as? String
        self.content.text = self.event["description"] as? String
        
        if let att = self.event["attendees"] as? [String] {
            self.peopleGoingLabel.text = "\(att.count) going • 0 following"
        }else{
            self.peopleGoingLabel.text = "0 going • 0 following"
        }

    }
    
    @objc func fbButtonPressed(button: UIButton)  {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventInfoViewController") as! EventInfoViewController
        vc.image = self.bigImage.image
        vc.fbEvent = self.fbEvent
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    @IBAction func openMap(_ sender: Any) {
        let location = self.event["locationLocalizable"] as! String
        var escapedString = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            if self.event["geolocation"] != nil {
                var cc = self.event["geolocation"] as! [Double]
                if cc.isEmpty {
                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(cc[0]),\(cc[1])&zoom=14")!, options: [:], completionHandler: { (completed) in })
                } else {
                    UIApplication.shared.open(URL(string:"comgooglemaps://?q=\(escapedString!)&zoom=14")!, options: [:], completionHandler: { (completed) in })
                }
            } else {
                UIApplication.shared.open(URL(string:"comgooglemaps://?q=\(escapedString!)&zoom=14")!, options: [:], completionHandler: { (completed) in })
            }
            
        } else {
            print("Can't use comgooglemaps://");
            if self.event["geolocation"] != nil {
                var cc = self.event["geolocation"] as! [Double]
                print(self.event)
                if cc.isEmpty {
                    UIApplication.shared.open(URL(string:"http://maps.apple.com/?ll=\(cc[0]),\(cc[1])")!, options: [:], completionHandler: { (completed) in })
                } else {
                    UIApplication.shared.open(URL(string:"http://maps.apple.com/?address=\(escapedString!)")!, options: [:], completionHandler: { (completed) in })
                 }
            } else {
                UIApplication.shared.open(URL(string:"http://maps.apple.com/?address=\(escapedString!)")!, options: [:], completionHandler: { (completed) in })
            }
            
        }
    }
    
    @IBAction func attending(_ sender: Any) {
        let key = self.fbEvent.key
        if let attendees = self.event["attendees"] as? NSMutableArray {
            attendees.add(Auth.auth().currentUser!.uid)
            let childUpdates = ["/events/\(key)/attendees": attendees]
            ref.updateChildValues(childUpdates)
            SVProgressHUD.showSuccess(withStatus: "Done")
            self.navigationController?.popViewController(animated: true)
        } else {
            let attendees : NSMutableArray = []
            attendees.add(Auth.auth().currentUser!.uid)
            let childUpdates = ["/events/\(key)/attendees": attendees]
            ref.updateChildValues(childUpdates)
            SVProgressHUD.showSuccess(withStatus: "Done")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func getUsers() {
        self.ref.child("Users").observe(.value, with: {(snapshot) -> Void in
            print(snapshot)
            var newItems = [DataSnapshot]()
            for item in snapshot.children {
                let user = item as! DataSnapshot
                if user.key == Auth.auth().currentUser!.uid {
                    let currentUser = user.value as! [String : AnyObject]
                    if let att = self.event["attendees"] as? [String] {
                        var followingAttending = 0
                        if let followingArray = currentUser["following"] as? [String] {
                            for following in followingArray {
                                if att.contains(following) {
                                   followingAttending = followingAttending + 1
                                }
                            }
                        }
                        if let att = self.event["attendees"] as? [String] {
                            self.peopleGoingLabel.text = "\(att.count) going • \(followingAttending) following"
                        }else{
                            self.peopleGoingLabel.text = "0 going • \(followingAttending) following"
                        }

                    }
                }
            }
        })
        
    }
    
    func getEventData(){
        self.ref.child("events/\(self.fbEvent.key)").observe(.value, with: {(snapshot) -> Void in
            for item in snapshot.children {
                self.updatedEvent = item as! DataSnapshot
            }
        })
    }

    
    
    

}
