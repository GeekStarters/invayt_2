//
//  RoundedButton.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/10/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit

@IBDesignable public class RoundedButton: UIButton {
    @IBInspectable var bgColor: UIColor = UIColor.clear {
        didSet {
            layer.backgroundColor = bgColor.cgColor
        }
    }
    
    @IBInspectable var fontColor: UIColor = UIColor.white{
        didSet {
            titleLabel?.textColor = fontColor
        }
    }

    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }


    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.frame.size.height / 2
    }
 

}
