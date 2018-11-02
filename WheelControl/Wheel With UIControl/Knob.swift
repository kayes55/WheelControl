//
//  Knob.swift
//  WheelControl
//
//  Created by Imrul Kayes on 3/7/18.
//  Copyright © 2018 Imrul Kayes. All rights reserved.
//

import UIKit

class Knob: UIControl {
    private var delegate: WheelProtocol?
    private var sections: Int?
    private var startTransform: CGAffineTransform?
    private var deltaAngle: Float?
    private var container: UIView?
    private var sectors: NSMutableArray?
    
    private var currentSector: Int?
    
    private var minAlphavalue = 0.6;
    private var maxAlphavalue = 1.0;
    
    init(frame: CGRect, sections: Int, del: Any) {
        super.init(frame: frame)
        
        self.sections = sections
        self.delegate = del as? WheelProtocol 
//        backgroundColor = tintColor
        
        drawWheel()
        
        self.currentSector = 0
        // changing delegate at the end
//        self.delegate?.wheelDidChange(newValue: "Value is \(String(describing: self.currentSector!))")
        self.delegate?.wheelDidChange(newValue: self.getSectorName(currentSector!))
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func drawWheel() {
        //1
        container = UIView(frame: self.bounds)
        // 2
        let angleSize: CGFloat = CGFloat(2 * Double.pi / Double(self.sections!))
        // 3
        for i in 0..<self.sections! {
//            // 4
//            let im = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
//            im.backgroundColor = UIColor.red
//            im.text = "\(i)"
//            im.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
//            // 5
//            im.layer.position = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
//            im.transform = CGAffineTransform(rotationAngle: angleSize * CGFloat(i))
//            im.tag = i
//            // 6
//            container?.addSubview(im)
            
            
            //4 - create imageview
            let im = UIImageView(image: UIImage(named: "segment.png"))
            im.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
            im.layer.position = CGPoint(x: (container?.bounds.size.width)!/2.0-(container?.frame.origin.x)!, y: (container?.bounds.size.height)!/2.0-(container?.frame.origin.y)!)
            im.transform = CGAffineTransform(rotationAngle: angleSize*CGFloat(i))
            im.alpha = CGFloat(minAlphavalue)
            im.tag = i
            
            if (i == 0) {
                im.alpha = CGFloat(maxAlphavalue)
            }
            
            //5 - Set sector image
            let sectorImage = UIImageView(frame: CGRect(x: 12, y: 15, width: 40, height: 40))
            sectorImage.image = UIImage(named: "icon\(i).png")
            im.addSubview(sectorImage)
            
            //6 - Add imageView to container
            container?.addSubview(im)
        }
        
        container?.isUserInteractionEnabled = false
        self.addSubview(container!)
        
        // 7.1 - Add background image
        let bg = UIImageView(frame: self.frame)
        bg.image = UIImage(named: "bg.png")
        self.addSubview(bg)
        // 7.2 adding center image
        let mask = UIImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        mask.image = UIImage(named: "centerButton.png")
        mask.center = self.center
        mask.center = CGPoint(x: mask.center.x, y: mask.center.y+3)
        self.addSubview(mask)
        
        //sectors count
        sectors = NSMutableArray(capacity: sections!)
        if (self.sections! % 2) == 0 {
            self.buildSectorsEven()
        } else {
            self.buildSectorsOdd()
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        //1
        let touchPoint: CGPoint = touch.location(in: self)
        // 1.1 - Get the distance from the center
        let dist: Float = calculateDistance(fromCenter: touchPoint)
        // 1.2 - Filter out touches too close to the center
        if dist < 40 || dist > 100 {
            // forcing a tap to be on the ferrule
            print("ignoring tap (\(touchPoint.x),\(touchPoint.y))")
            return false
        }
        // 2 - Calculate distance from center
        let dx: Float = Float(touchPoint.x - container!.center.x)
        let dy: Float = Float(touchPoint.y - container!.center.y)
        // 3 - Calculate arctangent value
        deltaAngle = atan2(dy, dx)
        // 4 - Save current transform
        startTransform = container!.transform
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let radians: CGFloat = CGFloat(atan2f(Float(container!.transform.b), Float(container!.transform.a)))
        print("rad is \(radians)")
        let pt: CGPoint = touch.location(in: self)
        let dx: Float = Float(pt.x - container!.center.x)
        let dy: Float = Float(pt.y - container!.center.y)
        let ang: Float = atan2(dy, dx)
        let angleDifference: Float = deltaAngle! - ang
        container?.transform = startTransform!.rotated(by: CGFloat(-angleDifference))
        
        // 5 - Set current sector's alpha value to the minimum value
        let im = self.getSectorByValue(currentSector!)
        im?.alpha = CGFloat(minAlphavalue)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        // 1 - Get current container rotation in radians
        let radians: CGFloat = CGFloat(atan2f(Float(container!.transform.b), Float(container!.transform.a)))
        // 2 - Initialize new value
        var newVal: CGFloat = 0.0
        // 3 - Iterate through all the sectors
        
        if let sec = sectors?.objectEnumerator().allObjects as? [Sector] {
            print(sec)
            
            for s in sec {
                // 4 - Check for anomaly (occurs with even number of sectors)
                if (s.minValue! > 0 && s.maxValue! < 0) {
                    if (s.maxValue! > radians || s.minValue! < radians) {
                        // 5 - Find the quadrant (positive or negative)
                        if (radians > 0) {
                            newVal = radians - .pi
                        } else {
                            newVal = .pi + radians
                        }
                        currentSector = s.sectorCount
                    }
                    
                }
                // 6 - All non-anomalous cases
                else if (radians > s.minValue! && radians < s.maxValue!) {
                    newVal = radians - s.midValue!
                    currentSector = s.sectorCount
                }
            }
            
//            self.delegate?.wheelDidChange(newValue: "Value is \(String(describing: self.currentSector!))")
            // 9 - changing delegate method
            self.delegate?.wheelDidChange(newValue: self.getSectorName(currentSector!))
            
            // 10 - Highlight selected sector
            let im = self.getSectorByValue(currentSector!)
            im?.alpha = CGFloat(maxAlphavalue)

        }
        
        
        // 7 - Set up animation for final rotation
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        let t: CGAffineTransform = container!.transform.rotated(by: -newVal)
        container?.transform = t
        UIView.commitAnimations()
    }
    
    private func calculateDistance(fromCenter: CGPoint) -> Float {
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let dx: Float = Float(fromCenter.x - center.x)
        let dy: Float = Float(fromCenter.y - center.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    private func buildSectorsEven() {
        // 1 - Define sector length
        let fanWidth: CGFloat = CGFloat((Double.pi * 2) / Double(sections!))
        // 2 - Set initial midpoint
        var mid: CGFloat = 0
        // 3 - Iterate through all sectors
        for i in 0..<sections! {
            let sector = Sector()
            // 4 - Set sector values
            sector.midValue = mid
            sector.minValue = mid - (fanWidth / 2)
            sector.maxValue = mid + (fanWidth / 2)
            sector.sectorCount = i
            if sector.maxValue! - fanWidth < -.pi {
                mid = .pi
                sector.midValue = mid
                sector.minValue = CGFloat(fabsf(Float(sector.maxValue!)))
            }
            mid -= fanWidth
            print("cl is \(sector)")
            // 5 - Add sector to array
            sectors?.add(sector)
        }
    }
    
    private func buildSectorsOdd() {
        // 1 - Define sector length
        let fanWidth: CGFloat = CGFloat((Double.pi * 2) / Double(sections!))
        // 2 - Set initial midpoint
        var mid: CGFloat = 0
        // 3 - Iterate through all sectors
        for i in 0..<sections! {
            let sector = Sector()
            // 4 - Set sector values
            sector.midValue = mid
            sector.minValue = mid - (fanWidth / 2)
            sector.maxValue = mid + (fanWidth / 2)
            sector.sectorCount = i
            mid -= fanWidth
//            if sector.minValue! < -.pi {
//                mid = -mid
//                mid -= fanWidth
//            }
            //MARK: This check is edited by Author Cesare Rocchi
            if mid < -.pi {
                mid = -mid
                mid -= fanWidth
            }
            // 5 - Add sector to array
            sectors?.add(sector)
            print("cl is \(sector)")
        }
    }
    
    //MARK:- Helper method
    private func getSectorByValue(_ value: Int) -> UIImageView? {
        var res: UIImageView?
        let views = container?.subviews
        for im in views! {
            if im.tag == value {
                res = im as? UIImageView
            }
        }
        return res
    }
    
    private func getSectorName(_ position: Int) -> String {
        var res = ""
        switch position {
        case 0:
            res = "Circles"
        case 1:
            res = "Flower"
        case 2:
            res = "Monster"
        case 3:
            res = "Person"
        case 4:
            res = "Smile"
        case 5:
            res = "Sun"
        case 6:
            res = "Swirl"
        case 7:
            res = "3 circles"
        case 8:
            res = "Triangle"
        default:
            break
        }
        return res
    }
}
