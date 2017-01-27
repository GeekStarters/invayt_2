//
//  Invayt.swift
//  Invayt
//
//  Created by Vincent Villalta on 1/10/17.
//  Copyright © 2017 Vincent Villalta. All rights reserved.
//

import UIKit

class Invayt: UIView {

    @IBOutlet weak var bigImage: UIImageView!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var hostedBy: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var eventcontent: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let view = UINib(nibName: "Invayt", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        
    }
}
