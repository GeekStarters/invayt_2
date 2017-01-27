//
//  ShareDirectViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 1/2/17.
//  Copyright © 2017 Vincent Villalta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class ShareDirectViewController: UIViewController {
    
    @IBOutlet weak var imageV: UIImageView!
    
    var createdEvent : FIRDatabaseReference!
    var image : UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageV.image = self.image
        // Do any additional setup after loading the view.
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
