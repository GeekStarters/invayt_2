//
//  ChatViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/18/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SVProgressHUD
import Firebase
import FirebaseDatabase
import SDWebImage
import Photos
import SwiftGifOrigin
import SWSegmentedControl
class ChatViewController: JSQMessagesViewController {

    private var messages = [JSQMessage]()
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    let defaults = UserDefaults.standard
    var conversation: Conversation?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var fbEvent: FIRDataSnapshot!
    
    fileprivate var displayName: String!
    
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("chats/\(self.fbEvent.key)")
    private var channelRefHandle: FIRDatabaseHandle?
    
    private lazy var messageRef: FIRDatabaseReference = self.channelRef.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?
    
    private lazy var userIsTypingRef: FIRDatabaseReference = self.channelRef.child("typingIndicator").child(self.senderId)
    private lazy var usersTypingQuery: FIRDatabaseQuery = self.channelRef.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)

    private var localTyping = false
    
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://invayt-3d279.appspot.com")
    private let imageURLNotSetKey = "NOTSET"
    
    private var updatedMessageRefHandle: FIRDatabaseHandle?

    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }

    @IBOutlet weak var segmentedContainer: UIView!
    override func viewDidLoad() {
        self.senderId = FIRAuth.auth()?.currentUser!.uid
        self.senderDisplayName = FIRAuth.auth()?.currentUser!.displayName
        super.viewDidLoad()
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        collectionView?.collectionViewLayout.springinessEnabled = false
        automaticallyScrollsToMostRecentMessage = true
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        self.observeMessages()
        
        let sc = SWSegmentedControl(items: ["All messages", "Organizer"])
        sc.addTarget(self, action: #selector(self.segmentedChanged(_:)), for: .valueChanged)
        sc.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.segmentedContainer.frame.size.height)
        sc.tintColor = UIColor.white
        self.segmentedContainer.addSubview(sc)
    }
    
    @IBAction func segmentedChanged(_ sender: SWSegmentedControl) {
        print("select: \(sender.selectedSegmentIndex)")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.black
        } else {
            cell.textView?.textColor = UIColor.white
        }
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "timestamp": "\(Date().timeIntervalSince1970)"
        ]
        isTyping = false
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if (indexPath.item % 13 == 0) {
            let message = self.messages[indexPath.item]
            print(message.date)
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item % 13 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {

        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return 0.0
        }

        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }

    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return nil
        }
        if message.senderId == self.senderId {
            return nil
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    //MARK: JSQMessages CollectionView DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    private func addMessage(withId id: String, name: String, text: String, date: Date) {
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text) {
            messages.append(message)
        }
        
        
    }
    
    private func observeMessages() {
        let messageQuery = messageRef.queryLimited(toLast:25)
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0{
                let date = Double(messageData["timestamp"]!)
                self.addMessage(withId: id, name: name, text: text, date: NSDate(timeIntervalSince1970: (date)!) as Date)
                self.finishReceivingMessage()
            }
            
            else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! {
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            }
            
            else {
                print("Error! Could not decode message data")
            }
        })
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }

    
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
        
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gif(data:data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    

}


import Foundation

struct Conversation {
    let firstName: String?
    let lastName: String?
    let preferredName: String?
    let smsNumber: String
    let id: String?
    let latestMessage: String?
    let isRead: Bool
}


import UIKit

let cellReuseIdentifier = "settingsCell"

public enum Setting: String{
    case removeBubbleTails = "Remove message bubble tails"
    case removeSenderDisplayName = "Remove sender Display Name"
    case removeAvatar = "Remove Avatars"
}

let defaults = UserDefaults.standard
var rows = [Setting]()
class SettingsTableViewController: UITableViewController {
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        rows = [.removeAvatar, .removeBubbleTails, .removeSenderDisplayName]
        // Set the Switch to the currents settings
        self.title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else {
            return UITableViewCell()
        }
        let row = rows[indexPath.row]
        let settingSwitch = UISwitch()
        settingSwitch.tag = indexPath.row
        settingSwitch.isOn = defaults.bool(forKey: row.rawValue)
        settingSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        cell.accessoryView = settingSwitch
        cell.textLabel?.text = row.rawValue
        
        return cell
    }
    func switchValueChanged(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: rows[sender.tag].rawValue)
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    //Mark: - Table view delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}


///////////////////
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            if let key = sendPhotoMessage() {
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    let path = "\(self.fbEvent.key)/chats/\(FIRAuth.auth()!.currentUser!.uid)\(Int(Date.timeIntervalSinceReferenceDate * 1000))\(photoReferenceUrl.lastPathComponent)"
                        self.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            image = self.imageWithImage(sourceImage: image, scaledToWidth: 600)
            if let key = sendPhotoMessage() {
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                let imagePath = "\(self.fbEvent.key)/chats/\(FIRAuth.auth()!.currentUser!.uid)\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}




