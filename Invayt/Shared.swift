//
//  Shared.swift
//  Invayt
//
//  Created by Vincent Villalta on 12/29/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage
import OneSignal
public func pushNotificationToUser(userTo: DataSnapshot, content: String){
    var ref: DatabaseReference!
    ref = Database.database().reference()
    let userDictionary = userTo.value as! [String : AnyObject]
    let notification = [
        "content": content,
        "timestamp": "\(Date().timeIntervalSince1970)"
    ]
    let cleanContent : String = content.html2String
    ref.child("notifications").child(userTo.key).childByAutoId().setValue(notification, withCompletionBlock: { (error, reference) in
        if error == nil {
            print("Notification created")
            if userDictionary["token"] != nil {
                OneSignal.postNotification(["contents": ["en": cleanContent], "include_player_ids": [userDictionary["token"] as! String], "data": ["objectId":"123"]], onSuccess: { (sucess) in
                    print(sucess)
                }, onFailure: { (error) in
                    print(error)
                })
            }
            
        } else {
            print(error ?? "Unkown error")
        }
    })

}


extension String {
    var html2AttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue, NSFontAttributeName   : UIFont.systemFont(ofSize: 17)], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}



public func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = NSDate()
    let earliest = now.earlierDate(date as Date)
    let latest = (earliest == now as Date) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else {
        return "Just now"
    }
    
}
