//
//  Wheel.swift
//  WheelControl
//
//  Created by Imrul Kayes on 3/7/18.
//  Copyright © 2018 Imrul Kayes. All rights reserved.
//

import UIKit

class Wheel: UIView {

    private var sectionNumber: Int?
    private var delegate: WheelProtocol?
    private var startTransform: CGAffineTransform?
    private var deltaAngle: Float?
    private var container: UIView?
    private var sectors: NSMutableArray?
    private var currentSector: Int?
    private var minAlphavalue = 0.6;
    private var maxAlphavalue = 1.0;
    
    init(frame: CGRect, delegate: Any, sections: Int) {
        super.init(frame: frame)
        self.sectionNumber = sections
        self.delegate = delegate as? WheelProtocol
        drawWheel()
        self.currentSector = 0
        self.delegate?.wheelDidChange(newValue: self.getSectorName(currentSector!))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func drawWheel() {
        container = UIView(frame: self.bounds)
        let angleSize: CGFloat = CGFloat(2 * Double.pi / Double(self.sectionNumber!))
        for i in 0..<self.sectionNumber! {
            let im = UIImageView(image: UIImage(named: "segment.png"))
            im.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
            im.layer.position = CGPoint(x: (container?.bounds.size.width)!/2.0-(container?.frame.origin.x)!, y: (container?.bounds.size.height)!/2.0-(container?.frame.origin.y)!)
            im.transform = CGAffineTransform(rotationAngle: angleSize*CGFloat(i))
            im.alpha = CGFloat(minAlphavalue)
            im.tag = i
            
            if (i == 0) {
                im.alpha = CGFloat(maxAlphavalue)
            }
            
            let sectorImage = UIImageView(frame: CGRect(x: 12, y: 15, width: 40, height: 40))
            sectorImage.image = UIImage(named: "icon\(i).png")
            im.addSubview(sectorImage)
            container?.addSubview(im)
        }
        
        container?.isUserInteractionEnabled = false
        self.addSubview(container!)
        
        let bg = UIImageView(frame: self.frame)
        bg.image = UIImage(named: "bg.png")
        self.addSubview(bg)
        let mask = UIImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        mask.image = UIImage(named: "centerButton.png")
        mask.center = self.center
        mask.center = CGPoint(x: mask.center.x, y: mask.center.y+3)
        self.addSubview(mask)
        
        sectors = NSMutableArray(capacity: sectionNumber!)
        if (self.sectionNumber! % 2) == 0 {
            self.buildSectorsEven()
        } else {
            self.buildSectorsOdd()
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint: CGPoint = touch.location(in: self)
            
            if let cont = container {
                let dist: Float = calculateDistance(fromCenter: touchPoint)
                if dist < 40 || dist > 100 {
                    return
                }
                let dx: Float = Float(touchPoint.x - cont.center.x)
                let dy: Float = Float(touchPoint.y - cont.center.y)
                deltaAngle = atan2(dy, dx)
                startTransform = cont.transform
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            if let cont = container {
                let pt: CGPoint = touch.location(in: self)
                let dist: Float = calculateDistance(fromCenter: pt)
                if dist < 40 || dist > 100 {
                    return
                }
                let dx: Float = Float(pt.x - cont.center.x)
                let dy: Float = Float(pt.y - cont.center.y)
                let ang: Float = atan2(dy, dx)
                let angleDifference: Float = deltaAngle! - ang
                cont.transform = startTransform!.rotated(by: CGFloat(-angleDifference))
                
                let im = self.getSectorByValue(currentSector!)
                im?.alpha = CGFloat(minAlphavalue)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let cont = container {
            let radians: CGFloat = CGFloat(atan2f(Float(cont.transform.b), Float(cont.transform.a)))
            var newVal: CGFloat = 0.0
            
            if let sec = sectors?.objectEnumerator().allObjects as? [Sector] {
                print(sec)
                
                for s in sec {
                    if (s.minValue! > 0 && s.maxValue! < 0) {
                        if (s.maxValue! > radians || s.minValue! < radians) {
                            if (radians > 0) {
                                newVal = radians - .pi
                            } else {
                                newVal = .pi + radians
                            }
                            currentSector = s.sectorCount
                        }
                        
                    }
                    else if (radians > s.minValue! && radians < s.maxValue!) {
                        newVal = radians - s.midValue!
                        currentSector = s.sectorCount
                    }
                }
                self.delegate?.wheelDidChange(newValue: self.getSectorName(currentSector!))
                
                let im = self.getSectorByValue(currentSector!)
                im?.alpha = CGFloat(maxAlphavalue)
            }
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            let t: CGAffineTransform = cont.transform.rotated(by: -newVal)
            cont.transform = t
            UIView.commitAnimations()
        }
    }
    
    private func calculateDistance(fromCenter: CGPoint) -> Float {
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let dx: Float = Float(fromCenter.x - center.x)
        let dy: Float = Float(fromCenter.y - center.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    private func buildSectorsEven() {
        let fanWidth: CGFloat = CGFloat((Double.pi * 2) / Double(sectionNumber!))
        var mid: CGFloat = 0
        for i in 0..<sectionNumber! {
            let sector = Sector()
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
            sectors?.add(sector)
        }
    }
    
    private func buildSectorsOdd() {
        let fanWidth: CGFloat = CGFloat((Double.pi * 2) / Double(sectionNumber!))
        var mid: CGFloat = 0
        for i in 0..<sectionNumber! {
            let sector = Sector()
            sector.midValue = mid
            sector.minValue = mid - (fanWidth / 2)
            sector.maxValue = mid + (fanWidth / 2)
            sector.sectorCount = i
            mid -= fanWidth

            if mid < -.pi {
                mid = -mid
                mid -= fanWidth
            }
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
