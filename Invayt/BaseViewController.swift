//
//  BaseViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/11/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "addEvent"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(BaseViewController.addTapped), for: UIControlEvents.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        navigationItem.rightBarButtonItem = barButton

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEvent") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
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
