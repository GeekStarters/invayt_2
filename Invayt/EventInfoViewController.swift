//
//  EventInfoViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/18/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class EventInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var image: UIImage!
    var fbEvent: FIRDataSnapshot!
    var options = ["Event info", "Event conversation", "Media", "Mute", "Participant list"]
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if indexPath.row == 0 {
            cell.imageView?.image = self.image
            cell.imageView?.layer.cornerRadius = 30
            cell.imageView?.clipsToBounds = true
        }
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.fbEvent = self.fbEvent
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 0 {
            self.navigationController?.popViewController(animated: true)
        } else if indexPath.row == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GaleryViewController") as! GaleryViewController
            vc.fbEvent = self.fbEvent
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 4 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
            vc.fbEvent = self.fbEvent
            vc.isShowingParticipantList = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        }else{
            return 45
        }
    }
}
