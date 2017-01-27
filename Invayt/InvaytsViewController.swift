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
class InvaytsViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    

    private var swipeView: DMSwipeCardsView<FIRDataSnapshot>!
    private var count = 0
    var ref: FIRDatabaseReference!
    var items = [FIRDataSnapshot]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.ref = FIRDatabase.database().reference()
        self.getEvents()
        
        let viewGenerator: (FIRDataSnapshot, CGRect) -> (UIView) = { (element: FIRDataSnapshot, frame: CGRect) -> (UIView) in
            let container : Invayt = Invayt(frame: CGRect(x: 30, y: 0, width: frame.width - 60, height: frame.height - 100))
            let invayt = element.value as! [String : AnyObject]
            print(invayt)
            
            let date = NSDate(timeIntervalSince1970: (invayt["timestamp"] as! Double)) as Date
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
            
            container.bigImage.sd_setImage(with: URL(string:invayt["image"] as! String))
            
            container.hostedBy.text = "Hosted by \(invayt["authorName"]!)"
            
            container.location.text = invayt["locationLocalizable"] as? String
            container.eventcontent.text = invayt["description"] as? String
            
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
            label.text = mode == .left ? "👍" : "👎"
            label.font = UIFont.systemFont(ofSize: 24)
            label.textAlignment = .center
            return label
        }
        
        let frame = CGRect(x: 0, y: 10, width: self.view.frame.width, height: self.view.frame.height - 160)
        swipeView = DMSwipeCardsView<FIRDataSnapshot>(frame: frame,
                                             viewGenerator: viewGenerator,
                                             overlayGenerator: overlayGenerator)
        swipeView.delegate = self
        self.view.addSubview(swipeView)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func decline(_ sender: Any) {
        self.swipeView.swipeTopCardLeft()
        
    }
    
    @IBAction func accept(_ sender: Any) {
        self.swipeView.swipeTopCardRight()
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
                let invayt = item as! FIRDataSnapshot
                let object = invayt.value as! [String: String]
                if object["userTo"] == FIRAuth.auth()?.currentUser!.uid {
                    
                    //var elements = []
                    self.ref.child("events/\(object["key"]!)").observeSingleEvent(of: .value, with: {(snapshot) -> Void in
                        self.swipeView.addCards([snapshot])
                        self.stackView.isHidden = false
                    })
                }
                
            }
        })
    }
    
    

}


extension InvaytsViewController: DMSwipeCardsViewDelegate {
    
    
    
    func swipedLeft(_ object: Any) {
        let iObject = object as! FIRDataSnapshot
        print("Swiped left: \(object)")
        self.ref.child("invayts").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) -> Void in
            for item in snapshot.children {
                let invayt = item as! FIRDataSnapshot
                let object = invayt.value as! [String: String]
                if object["key"] ==  iObject.key{
                    self.ref.child("invayts/\(invayt.key)").removeValue()
                }
            }
        })
    }
    
    func swipedRight(_ object: Any) {
        print("Swiped right: \(object)")
        let iObject = object as! FIRDataSnapshot
        let key = iObject.key
        let o = iObject.value as! [String : AnyObject]
        if let attendees = o["attendees"] as? NSMutableArray {
            attendees.add(FIRAuth.auth()!.currentUser!.uid)
            let childUpdates = ["/events/\(key)/attendees": attendees]
            ref.updateChildValues(childUpdates)
        } else {
            let attendees : NSMutableArray = []
            attendees.add(FIRAuth.auth()!.currentUser!.uid)
            let childUpdates = ["/events/\(key)/attendees": attendees]
            ref.updateChildValues(childUpdates)
        }
        self.ref.child("invayts/\(key)").removeValue()
    }
    
    
    func cardTapped(_ object: Any) {
        print("Tapped on: \(object)")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsViewController") as! EventDetailsViewController
        vc.fbEvent = object as! FIRDataSnapshot
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func reachedEndOfStack() {
        print("Reached end of stack")
        self.stackView.isHidden = true
    }
}
