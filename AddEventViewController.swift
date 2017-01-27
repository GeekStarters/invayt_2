//
//  AddEventViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 12/2/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import GMStepper
import Fusuma
import Firebase
import FirebaseDatabase
import MapKit
import GMStepper
import SVProgressHUD

class AddEventViewController: UIViewController, FusumaDelegate, MKMapViewDelegate, SetDateForEventDelegate, UITextFieldDelegate {


    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aditionalOptions: UIView!
    @IBOutlet weak var extraInfoHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonBottom: NSLayoutConstraint!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var canInvite: UISwitch!
    @IBOutlet weak var cohost: UITextField!
    @IBOutlet weak var maxAttendees: GMStepper!
    @IBOutlet weak var maximunPerperson: GMStepper!
    @IBOutlet weak var showAditionalOptions: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var moreDetailsLabel: UILabel!
    
    var alreadySent = false
    var image: UIImage!
    let dbRef = "https://invayt-3d279.firebaseio.com/"
    var ref: FIRDatabaseReference!
    let storageRef = "gs://invayt-3d279.appspot.com"
    let storage = FIRStorage.storage()
    var createdEvent : FIRDatabaseReference!
    var date: Date!
    
    var eventDateFormatted : Date!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventLocation.addTarget(self, action: #selector(self.eventLocationSeted), for: UIControlEvents.editingDidEnd)
        ref = FIRDatabase.database().reference()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        

        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "nextArrow"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(getter: self.next), for: UIControlEvents.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20) //CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem.init(customView: button)
        
        navigationItem.rightBarButtonItem = barButton
        
        
        let close = UIButton.init(type: .custom)
        close.setImage(UIImage.init(named: "close"), for: UIControlState.normal)
        close.addTarget(self, action:#selector(self.close), for: UIControlEvents.touchUpInside)
        close.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20) //CGRectMake(0, 0, 30, 30)
        let closeBar = UIBarButtonItem.init(customView: close)
        
        navigationItem.leftBarButtonItem = closeBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700)
    }
    
    func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        self.buttonBottom.constant = keyboardFrame.height
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = .zero
        self.buttonBottom.constant = 0
        self.scrollView.contentInset = contentInset
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

    @IBAction func showAditionalOptions(_ sender: Any) {
        self.extraInfoHeight.constant = 290
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @IBAction func selectDate(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DateSelectorViewController") as! DateSelectorViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
  
    @IBAction func camera(_ sender: Any) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false // If you want to let the users allow to use video.
        self.present(fusuma, animated: true, completion: nil)
    }
    
    func fusumaImageSelected(_ image: UIImage) {
        print("Image selected")
        self.image = image
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }
    
    @IBAction func next(_ sender: Any) {
        if (self.eventName.text?.characters.count)! > 0
            && (self.eventDate.text?.characters.count)! > 0
            && (self.eventDescription.text.characters.count) > 0
        {
            if self.alreadySent == false {
            SVProgressHUD.show(withStatus: "Uploading image")
            var data = Data()
            data = UIImageJPEGRepresentation(self.image, 0.8)!
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/eventimage/\(Int(arc4random_uniform(8472074) + 1)).jpg"
            print(filePath)
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            let storageRef = storage.reference()
            let eventImagesRef = storageRef.child(filePath)
            
            
            let uploadTask = eventImagesRef.put(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("upload error")
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    print(error?.localizedDescription ?? "Unknown error")
                    return
                }
                SVProgressHUD.show()
                print(metadata)
                let event = ["name": self.eventName.text!,
                             "date": self.eventDate.text,
                             "dateFormated": "\(self.date!)",
                             "locationLocalizable": self.eventLocation.text ?? "",
                             "description": self.eventDescription.text,
//                             "geolocation": [self.mapView.annotations[0].coordinate.latitude, self.mapView.annotations[0].coordinate.longitude],
                             "author": FIRAuth.auth()?.currentUser!.uid,
                             "authorName": FIRAuth.auth()?.currentUser!.displayName,
                             "price": "Free",
                             "maximun": self.maxAttendees.value,
                             "perUser": self.maximunPerperson.value,
                             "image": metadata.downloadURL()?.absoluteString,
                             "timestamp": self.date.timeIntervalSince1970,
                             "hashtags": self.cohost.text,
                             "attendees" : []
                    ]
                    as [String : Any]
                self.ref.child("events").childByAutoId().setValue(event, withCompletionBlock: { (error, reference) in
                    if error == nil {
                        SVProgressHUD.showSuccess(withStatus: "Success")
                        print("Event created")
                        self.alreadySent = true
                        self.createdEvent = reference
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinishAddingEventViewController") as! FinishAddingEventViewController
                        vc.createdEvent = self.createdEvent
                        vc.image = self.image
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                })
            }
                }
            else{
                let event = ["name": self.eventName.text!,
                             "date": self.eventDate.text,
                             "dateFormated": "\(self.date!)",
                    "locationLocalizable": self.eventLocation.text!,
                    "description": self.eventDescription.text,
                    "geolocation": [self.mapView.annotations[0].coordinate.latitude, self.mapView.annotations[0].coordinate.longitude],
                    "author": FIRAuth.auth()?.currentUser!.uid,
                    "authorName": FIRAuth.auth()?.currentUser!.displayName,
                    "price": "Free",
                    "maximun": self.maxAttendees.value,
                    "perUser": self.maximunPerperson.value,
                    "timestamp": self.date.timeIntervalSince1970,
                    "attendees" : []
                    ]
                    as [String : Any]
                self.createdEvent.updateChildValues(event, withCompletionBlock: {(error, reference) in
                    if error == nil {
                        SVProgressHUD.showSuccess(withStatus: "Updated")
                        print("Event created")
                        self.alreadySent = true
                        self.createdEvent = reference
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinishAddingEventViewController") as! FinishAddingEventViewController
                        vc.createdEvent = self.createdEvent
                        vc.image = self.image
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    func setDateForEvent(selectedDate: Date) {
        self.date = selectedDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        let d = dateFormatter.string(from: selectedDate)
        self.eventDateFormatted = selectedDate
        self.eventDate.text = d
    }
    
    func eventLocationSeted() {
        if (self.eventLocation.text?.characters.count)! > 18 {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(self.eventLocation.text!, completionHandler: { (placemarks, error) in
                if (placemarks?.count)! > 0 {
                    if let placemark = placemarks![0] as? CLPlacemark {
                        let allAnnotations = self.mapView.annotations
                        self.mapView.removeAnnotations(allAnnotations)
                        self.mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake((placemark.location?.coordinate.latitude)!, (placemark.location?.coordinate.longitude)!), MKCoordinateSpanMake(0.001, 0.001)), animated: true)
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                    
                    }
                }
                
            })
        }
    }
    
}
