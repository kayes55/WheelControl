//
//  Sector.swift
//  WheelControl
//
//  Created by Imrul Kayes on 3/7/18.
//  Copyright © 2018 Imrul Kayes. All rights reserved.
//

import UIKit

class Sector: NSObject {
    
    var minValue: CGFloat?
    var maxValue: CGFloat?
    var midValue: CGFloat?
    var sectorCount: Int?

    
    override var description: String {
        return "\(String(describing: sectorCount!)), \(String(describing: minValue!)), \(String(describing: midValue!)), \(String(describing: maxValue!))"
    }
}
