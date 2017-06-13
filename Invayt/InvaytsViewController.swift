//
//  InvaytsViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 12/2/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseDatabase
class InvaytsViewController: BaseViewController {
    @IBOutlet weak var stackView: UIStackView!
    

    private var swipeView: DMSwipeCardsView<DataSnapshot>!
    private var count = 0
    var ref: DatabaseReference!
    var items = [DataSnapshot]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.ref = Database.database().reference()
        self.getEvents()
        self.title = "Invayts"
        let viewGenerator: (DataSnapshot, CGRect) -> (UIView) = { (element: DataSnapshot, frame: CGRect) -> (UIView) in
            let container : Invayt = Invayt(frame: CGRect(x: 30, y: 0, width: frame.width - 60, height: frame.height - 100))
            let invayt = element.value as! [String : AnyObject]
            print(invayt)
            
            self.ref.child("events/\(invayt["key"]!)").observeSingleEvent(of: .value, with: {(snapshot) -> Void in
                let content = snapshot.value as! [String : AnyObject]
                let date = NSDate(timeIntervalSince1970: (content["timestamp"] as! Double)) as Date
                let df = DateFormatter()
                df.dateStyle = .none
                df.timeStyle = .short
                container.time.text = df.string(from: date)
                
                let df2 = DateFormatter()
                df2.dateFormat = "dd"
                container.day.text = df2.string(from: date)
                
                let df3 = DateFormatter()
                df3.dateFormat = "MMM"
                container.month.text = df3.string(from: date).uppercased()
                
                container.bigImage.sd_setImage(with: URL(string:content["image"] as! String))
                
                container.hostedBy.text = "Hosted by \(content["authorName"]!)"
                
                container.location.text = content["locationLocalizable"] as? String
                container.eventcontent.text = content["description"] as? String
                container.name.text = content["name"] as? String
                
            })
            
            self.ref.child("Users/\(invayt["userFrom"] as! String)").observeSingleEvent(of: .value, with: {(snapshot) -> Void in
                let invayter = snapshot.value as! [String : AnyObject]
                container.invayterName.text = invayter["name"] as? String
                if invayt["photoURL"] as? String != nil {
                    container.invayterImage.sd_setImage(with: URL(string:invayter["photoURL"] as! String))
                } else {
                    container.invayterImage.removeFromSuperview()
                }
            })
            
            container.layer.shadowRadius = 4
            container.layer.shadowOpacity = 1.0
            container.layer.shadowColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            container.layer.shadowOffset = CGSize(width: 0, height: 0)
            container.layer.shouldRasterize = true
            container.layer.rasterizationScale = UIScreen.main.scale
            
            return container
        }
        
        let overlayGenerator: (SwipeMode, CGRect) -> (UIView) = { (mode: SwipeMode, frame: CGRect) -> (UIView) in
            let label = UILabel()
            label.frame.size = CGSize(width: 100, height: 100)
            label.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
            label.layer.cornerRadius = label.frame.width / 2
            label.backgroundColor = mode == .left ? UIColor.red : UIColor.green
            label.clipsToBounds = true
            label.text = mode == .left ? "👎" : "👍"
            label.font = UIFont.systemFont(ofSize: 24)
            label.textAlignment = .center
            return label
        }
        
        let frame = CGRect(x: 0, y: 10, width: self.view.frame.width, height: self.view.frame.height - 160)
        swipeView = DMSwipeCardsView<DataSnapshot>(frame: frame,
                                             viewGenerator: viewGenerator,
                                             overlayGenerator: overlayGenerator)
        swipeView.delegate = self
        self.view.addSubview(swipeView)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func decline(_ sender: Any) {
        
    }
    
    @IBAction func accept(_ sender: Any) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getEvents() {
        SVProgressHUD.show()
        self.ref.child("invayts").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) -> Void in
            SVProgressHUD.dismiss()
            for item in snapshot.children {
                let invayt = item as! DataSnapshot
                let object = invayt.value as! [String: String]
                if object["userTo"] == Auth.auth().currentUser!.uid {
                    self.swipeView.addCards([invayt])
                    self.stackView.isHidden = false
                    //var elements = []
                    
                }
                
            }
        })
    }
    

}


extension InvaytsViewController: DMSwipeCardsViewDelegate {
    
    
    
    func swipedLeft(_ object: Any) {
        let iObject = object as! DataSnapshot
        print("Swiped left: \(object)")
        let key = iObject.key
        self.ref.child("invayts/\(key)").removeValue()
    }
    
    func swipedRight(_ object: Any) {
        print("Swiped right: \(object)")
        let iObject = object as! DataSnapshot
        let key = iObject.key
        let o = iObject.value as! [String : AnyObject]
        if let attendees = o["attendees"] as? NSMutableArray {
            attendees.add(Auth.auth().currentUser!.uid)
            let childUpdates = ["/events/\(key)/attendees": attendees]
            ref.updateChildValues(childUpdates)
        } else {
            let attendees : NSMutableArray = []
            attendees.add(Auth.auth().currentUser!.uid)
            let childUpdates = ["/events/\(key)/attendees": attendees]
            ref.updateChildValues(childUpdates)
        }
        self.ref.child("invayts/\(key)").removeValue()
    }
    
    
    func cardTapped(_ object: Any) {
        print("Tapped on: \(object)")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsViewController") as! EventDetailsViewController
        vc.fbEvent = object as! DataSnapshot
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func reachedEndOfStack() {
        print("Reached end of stack")
        self.stackView.isHidden = true
    }
}
