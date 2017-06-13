//
//  GaleryViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 12/28/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage
import SwiftGifOrigin
import ADMozaicCollectionViewLayout
import SVProgressHUD

enum ADMozaikLayoutType {
    case portrait
    case landscape
}


class GaleryViewController: UIViewController, UICollectionViewDataSource, ADMozaikLayoutDelegate {

    var database: Database!
    var storage: Storage!
    var fbEvent: DataSnapshot!

    
    var picArray = [UIImage]()
    
    fileprivate let ADMozaikCollectionViewLayoutExampleImagesCount = 22
    fileprivate var portraitLayout: ADMozaikLayout {
        let columns = [ADMozaikLayoutColumn(width: 93), ADMozaikLayoutColumn(width: 93), ADMozaikLayoutColumn(width: 93), ADMozaikLayoutColumn(width: 93)]
        let layout = ADMozaikLayout(rowHeight: 93, columns: columns)
        layout.delegate = self
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        return layout;
    }
    
    fileprivate var landscapeLayout: ADMozaikLayout {
        let columns = [ADMozaikLayoutColumn(width: 110), ADMozaikLayoutColumn(width: 110), ADMozaikLayoutColumn(width: 111), ADMozaikLayoutColumn(width: 111), ADMozaikLayoutColumn(width: 110), ADMozaikLayoutColumn(width: 110)]
        let layout = ADMozaikLayout(rowHeight: 110, columns: columns)
        layout.delegate = self
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        return layout;
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = Database.database()
        storage = Storage.storage()
        getAllPictures()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setCollectionViewLayout(false, ofType: UIScreen.main.bounds.width > UIScreen.main.bounds.height ? .landscape : .portrait)
    }
    
    fileprivate func setCollectionViewLayout(_ animated: Bool, ofType type: ADMozaikLayoutType) {
        self.collectionView.collectionViewLayout.invalidateLayout()
        if type == .landscape {
            self.collectionView.setCollectionViewLayout(self.landscapeLayout, animated: true)
        }
        else {
            self.collectionView.setCollectionViewLayout(self.portraitLayout, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, mozaikSizeForItemAtIndexPath indexPath: IndexPath) -> ADMozaikLayoutSize {
        if indexPath.item == 0 {
            return ADMozaikLayoutSize(numberOfColumns: 1, numberOfRows: 1)
        }
        if indexPath.item % 8 == 0 {
            return ADMozaikLayoutSize(numberOfColumns: 2, numberOfRows: 2)
        }
        else if indexPath.item % 6 == 0 {
            return ADMozaikLayoutSize(numberOfColumns: 3, numberOfRows: 1)
        }
        else if indexPath.item % 4 == 0 {
            return ADMozaikLayoutSize(numberOfColumns: 1, numberOfRows: 3)
        }
        else {
            return ADMozaikLayoutSize(numberOfColumns: 1, numberOfRows: 1)
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : galerryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! galerryCollectionViewCell
        //let imageView: UIImageView = cell.viewWithTag(1000) as! UIImageView
        cell.pic.image = self.picArray[indexPath.row]
        return cell
    }
    
   
    
    private func getAllPictures(){
        SVProgressHUD.show()
        let dbRef = database.reference().child("chats/\(self.fbEvent.key)/messages")
        dbRef.observe(.childAdded, with: { (snapshot) in
            // Get download URL from snapshot
            let messageData = snapshot.value as! Dictionary<String, String>
            if let photoURL = messageData["photoURL"] as String! {
                if photoURL.hasPrefix("gs://") {
                    print(photoURL)
                    let storageRef = Storage.storage().reference(forURL: photoURL)
                    storageRef.getData(maxSize: INT64_MAX){ (data, error) in
                        if let error = error {
                            print("Error downloading image data: \(error)")
                            return
                        }
                        storageRef.getMetadata(completion: { (metadata, metadataErr) in
                            if let error = metadataErr {
                                print("Error downloading metadata: \(error)")
                                return
                            }
                            
                            if (metadata?.contentType == "image/gif") {
                                self.picArray.append(UIImage.gif(data:data!)!)
                            } else {
                                self.picArray.append(UIImage.init(data: data!)!)
                            }
                            self.collectionView.reloadData()
                            SVProgressHUD.dismiss()
                        })
                    }
                }
            }
        })
    }


}

class galerryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pic: UIImageView!
}
