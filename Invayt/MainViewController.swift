//
//  MainViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/11/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var arrayOfImageNameForUnselectedState : [String] = ["calendar_off", "invayts_off", "discover_off", "alerts_off", "me_off"]
        var arrayOfImageNameForSelectedState : [String] = ["calendar_on", "invayts_on", "discover_on", "alerts_on", "me_on" ]
        if let count = self.tabBar.items?.count {
            for i in 0...(count-1) {
                let imageNameForSelectedState   = arrayOfImageNameForSelectedState[i]
                let imageNameForUnselectedState = arrayOfImageNameForUnselectedState[i]
                
                self.tabBar.items?[i].selectedImage = UIImage(named: imageNameForSelectedState)?.withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[i].image = UIImage(named: imageNameForUnselectedState)?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        let selectedColor   = UIColor(red:0.55, green:0.78, blue:0.31, alpha:1.0)
        let unselectedColor = UIColor(red:0.36, green:0.36, blue:0.36, alpha:1.0)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: unselectedColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: selectedColor], for: .selected)
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
