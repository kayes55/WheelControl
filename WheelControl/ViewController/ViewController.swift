//
//  ViewController.swift
//  WheelControl
//
//  Created by Imrul Kayes on 3/6/18.
//  Copyright © 2018 Imrul Kayes. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, WheelProtocol {

    var wheel: Wheel!
    var knob: Knob!
    
    var sectorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding a Label
        sectorLabel = UILabel(frame: CGRect(x: self.view.frame.width/2 - 60, y: 410, width: 120, height: 40))
        sectorLabel.textAlignment = .center
        sectorLabel.backgroundColor = UIColor.lightGray
        self.view.addSubview(sectorLabel)
        
        // Wheel is made of UIView class
        wheel = Wheel(frame: CGRect(x: 0, y: 0, width: 200, height: 200), delegate: self, sections: 9)
        wheel.center = CGPoint(x: self.view.frame.width/2, y: 300)
        self.view.addSubview(wheel)
        
        
        
        //MARK: - This Knob is made of UIControl class. You can use it also.
        /*
         
         knob = Knob(frame: CGRect(x: 0, y: 0, width: 200, height: 200), sections: 9, del: self)
         knob.center = CGPoint(x: self.view.frame.width/2, y: 300)
         self.view.addSubview(knob)
 
 
        */
        
        
        
    }
    //MARK: - Delegate Function
    func wheelDidChange(newValue: String) {
        self.sectorLabel.text = newValue
    }

}

