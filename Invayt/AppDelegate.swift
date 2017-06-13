//
//  AppDelegate.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/9/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import OneSignal
import Fabric
import Branch
import TwitterKit
import Bugsee
import Bugsnag
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ref: DatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Bugsnag.start(withApiKey: "1ba61549bd0283ad06903d3a34298cd1")
        
        FirebaseApp.configure()
        OneSignal.initWithLaunchOptions(launchOptions, appId: "8dfd5f2c-702c-4ce7-a52b-cd57d9b7a7c5")
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //Fabric.with([Twitter.self, Branch.self])
        Bugsee.launch(token :"0f8e1516-4091-4985-bceb-505f732222b2")

        if (Auth.auth().currentUser) != nil {
            // User is signed in.
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController : MainViewController = storyboard.instantiateViewController(withIdentifier:"MainViewController") as! MainViewController
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            ref = Database.database().reference()
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            if status.permissionStatus.hasPrompted {
                if status.permissionStatus.status == .authorized {
                    let userID = status.subscriptionStatus.userId
                    let childUpdates = ["/Users/\(Auth.auth().currentUser!.uid)/token": userID!]
                    ref.updateChildValues(childUpdates)
                    OneSignal.syncHashedEmail(Auth.auth().currentUser?.email)
                    OneSignal.sendTag("user_token", value: Auth.auth().currentUser?.uid)
                }
            }
            
            Branch.getInstance().initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
                guard error == nil else { return }
                guard let userDidClick = params?["+clicked_branch_link"] as? Bool else { return }
                if userDidClick {
                    // This code will execute when your app is opened from a Branch deep link, which
                    // means that you can route to a custom activity depending on what they clicked.
                    // In this example, we'll just print out the data from the link that was clicked.
                    print("deep link data: ", params)
                    // Load a reference to the storyboard and grab a reference to the navigation controller
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                }
            })
        } else {
            // No user is signed in.
        }
        
        

        return true
    }

    // Respond to URI scheme links
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // For Branch to detect when a URI scheme is clicked
        Branch.getInstance().handleDeepLink(url as URL!)
        print("URL: \(url)")
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    // Respond to Universal Links
    private func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: @escaping ([AnyObject]?) -> Void) -> Bool {
        // For Branch to detect when a Universal Link is clicked
        Branch.getInstance().continue(userActivity)
        print("URL:2 \(userActivity)")
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("url \(url)")
        print("url \(url.host!)")
        print("url \(url.path)")
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("url \(url)")
        print("url \(url.host!)")
        print("url \(url.path)")
        
        var urlPath : String = url.path as String!
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        /*if(urlPath == "/about"){
            var aboutVC: AboutViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AboutViewController") as! AboutViewController
            self.window?.rootViewController = aboutVC
            
        }else if(urlPath == "/help"){
            var helpVC: HelpViewController = mainStoryboard.instantiateViewControllerWithIdentifier("HelpViewController") as! HelpViewController
            self.window?.rootViewController = helpVC
            
        }else if(urlPath == "/contact"){
            
            var contactVC: ContactViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ContactViewController") as! ContactViewController
            self.window?.rootViewController = contactVC
        }*/
        
        
        self.window?.makeKeyAndVisible()
        return true
    }
}

