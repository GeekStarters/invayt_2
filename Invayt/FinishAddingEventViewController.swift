//
//  FinishAddingEventViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 1/2/17.
//  Copyright © 2017 Vincent Villalta. All rights reserved.
//

import UIKit
import SJSegmentedScrollView
import Firebase
import FirebaseDatabase
class FinishAddingEventViewController: SJSegmentedViewController {
    var createdEvent : FIRDatabaseReference!
    var image : UIImage!
    
    var selectedSegment: SJSegmentTab?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let storyboard = self.storyboard {
            
            let firstViewController = storyboard.instantiateViewController(withIdentifier: "ShareDirectViewController") as! ShareDirectViewController
            firstViewController.createdEvent = self.createdEvent
            firstViewController.image = self.image
            firstViewController.title = "All Followers"
            
            let secondViewController = storyboard.instantiateViewController(withIdentifier: "ShareFollowersViewController") as! ShareFollowersViewController
            secondViewController.createdEvent = self.createdEvent
            secondViewController.title = "Direct"
            
            
            headerViewController = nil
            segmentControllers = [firstViewController, secondViewController]
            headerViewHeight = -10
            selectedSegmentViewHeight = 5.0
            segmentTitleColor = .white
            
            selectedSegmentViewColor = .white
            segmentShadow = SJShadow.light()
            segmentBackgroundColor = (self.navigationController?.navigationBar.barTintColor)!
            delegate = self
        }
        title = "Share event"
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "check"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(FinishAddingEventViewController.close), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    

}


extension FinishAddingEventViewController: SJSegmentedViewControllerDelegate {
    
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        if segments.count > 0 {
            selectedSegment = segments[index]
        }
    }
}
