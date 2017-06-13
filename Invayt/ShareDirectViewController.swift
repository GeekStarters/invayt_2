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
import Font_Awesome_Swift
import Branch
import FBSDKShareKit
import FBSDKLoginKit
class ShareDirectViewController: UIViewController {
    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var twitter: UIButton!
    @IBOutlet weak var copyText: UIButton!
    @IBOutlet weak var whatsAPp: UIButton!
    @IBOutlet weak var comment: UITextView!
    
    var createdEvent : DatabaseReference!
    var image : UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageV.image = self.image
        
        
        self.facebook.setFAText(prefixText: "", icon: .FAFacebookSquare, postfixText: " Facebook", size: 30, forState: .normal)
        self.twitter.setFAText(prefixText: "", icon: .FATwitterSquare, postfixText: " Twitter", size: 30, forState: .normal)
        self.copyText.setFAText(prefixText: "", icon: .FAPaperclip, postfixText: " Copy", size: 30, forState: .normal)
        self.whatsAPp.setFAText(prefixText: "", icon: .FAWhatsapp, postfixText: " WhatsApp", size: 30, forState: .normal)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    @IBAction func shareOnFacebook(_ sender: Any) {
//        if FBSDKAccessToken.current().hasGranted("publish_actions") {
//            self.shareFB()
//        } else {
//            let loginManager = LoginManager()
//            loginManager.logIn([ .publishActions ], viewController: self) { loginResult in
//                switch loginResult {
//                case .failed(let error):
//                    print(error)
//                case .cancelled:
//                    print("User cancelled login.")
//                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                    print("Logged in!")
//                    self.shareFB()
//                }
//            }
//        }
    }
    
    
    func shareFB(){
        
    }
        
    @IBAction func shareOnthers(_ sender: Any) {
        var branchUniversalObject = BranchUniversalObject(canonicalIdentifier: "event_id_\(createdEvent.key)")
        branchUniversalObject.title = "Check out my new event"
        branchUniversalObject.contentDescription = (self.comment.text != "Comment") ? self.comment.text : ""
        branchUniversalObject.addMetadataKey("event_id", value: createdEvent.key)
        branchUniversalObject.registerView()
        branchUniversalObject.listOnSpotlight()
        
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        branchUniversalObject.showShareSheet(with: linkProperties,
                                             andShareText: (self.comment.text != "Comment") ? self.comment.text : "",
                                             from: self,
                                             completion: { (activityType, completed) in
                                                if (completed) {
                                                    // This code path is executed if a successful share occurs
                                                }
        })
        
        
    }
    
    func getBranchLink() -> String {
        var branchUniversalObject = BranchUniversalObject(canonicalIdentifier: "event_id_\(createdEvent.key)")
        branchUniversalObject.title = "Check out my new event"
        branchUniversalObject.contentDescription = (self.comment.text != "Comment") ? self.comment.text : ""
        branchUniversalObject.addMetadataKey("event_id", value: createdEvent.key)
        branchUniversalObject.registerView()
        branchUniversalObject.listOnSpotlight()
        
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        return branchUniversalObject.getShortUrl(with: linkProperties)!
    }

    /*
     // Hook up your share button to initiate sharing. In your live app, you probably want to style this.
     let button = UIButton(frame: CGRect(x: 80.0, y: 210.0, width: 160.0, height: 40.0))
     button.addTarget(self, action: #selector(initiateSharing), forControlEvents: .TouchUpInside)
     button.setTitle("Share Link", forState: .Normal)
     button.center = self.view.center
     button.backgroundColor = .grayColor()
     self.view.addSubview(button)
     // Initialize a Branch Universal Object for the page the user is viewing
     branchUniversalObject = BranchUniversalObject(canonicalIdentifier: "item_id_12345")
     // Define the content that the object represents
     branchUniversalObject.title = "My Content Title"
     branchUniversalObject.contentDescription = "Check out this awesome piece of content"
     branchUniversalObject.imageUrl  = "https://example.com/mycontent-12345.png"
     branchUniversalObject.addMetadataKey("item_id", value: "12345")
     branchUniversalObject.addMetadataKey("user_id", value: "678910")
     // Trigger a view on the content for analytics tracking
     branchUniversalObject.registerView()
     // List on Apple Spotlight
     branchUniversalObject.listOnSpotlight()

     
     // This is the function to handle sharing when a user clicks the share button
     func initiateSharing() {
     // Create your link properties
     // More link properties available at https://dev.branch.io/getting-started/configuring-links/guide/#link-control-parameters
     let linkProperties = BranchLinkProperties()
     linkProperties.feature = "sharing"
     // Show the share sheet for the content you want the user to share. A link will be automatically created and put in the message.
     branchUniversalObject.showShareSheetWithLinkProperties(linkProperties,
     andShareText: "Hey friend - I know you'll love this: ",
     fromViewController: self,
     completion: { (activityType, completed) in
     if (completed) {
     // This code path is executed if a successful share occurs
     }
     })
     }

    */

}
