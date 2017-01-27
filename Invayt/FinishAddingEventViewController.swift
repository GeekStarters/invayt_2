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
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension FinishAddingEventViewController: SJSegmentedViewControllerDelegate {
    
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        if segments.count > 0 {
            selectedSegment = segments[index]
        }
    }
}
