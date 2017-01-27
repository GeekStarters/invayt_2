//
//  NotificationsViewController.swift
//  
//
//  Created by Vincent Villalta on 12/2/16.
//
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseDatabase
class NotificationsViewController: BaseViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var ref: FIRDatabaseReference!
    var items = [FIRDataSnapshot]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        self.getNotificatons()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        self.title = "Notifications"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : NotificationCell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as! NotificationCell
        let event = self.items[indexPath.row]
        let row = event.value as! [String : AnyObject]
        let content = row["content"] as? String
        let contentWIthStyle = "<span style=\"font-family: helvetica; font-size: 17\">\(content!)</span>"
        cell.notificationContent.attributedText = contentWIthStyle.html2AttributedString
        cell.notificationContent.numberOfLines = 0
        let date = NSDate(timeIntervalSince1970: (Double(row["timestamp"] as! String))!)
        cell.notificationDate.text = timeAgoSinceDate(date: date, numericDates: true)
        return cell
    }

    
    func getNotificatons() {
        SVProgressHUD.show()
        self.ref.child("notifications/\(FIRAuth.auth()!.currentUser!.uid)").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            print(snapshot)
            var newItems = [FIRDataSnapshot]()
            for item in snapshot.children {
                newItems.append(item as! FIRDataSnapshot)
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        
    }
}

class NotificationCell: UITableViewCell {
    @IBOutlet weak var notificationDate: UILabel!
    @IBOutlet weak var notificationContent: UILabel!
    
}




