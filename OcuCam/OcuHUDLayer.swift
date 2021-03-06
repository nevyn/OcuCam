//
//  OcuHUDLayer.swift
//  OcuHUD
//
//  Created by Joachim Bengtsson on 2014-10-24.
//  Copyright (c) 2014 Thirdcog. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

func frand() -> Double
{
	return Double(arc4random_uniform(1000))/1000.0
}

class OcuHUDLayer : CALayer {
	
	let circle = CAShapeLayer()
	let thickArc = CAShapeLayer()
	var lines : [CAShapeLayer] = []
	let endAngle = Double.pi * 1.2
	func commonInit() {
        let color1 = UIColor(white: 0.5, alpha: 0.6).cgColor
        let color2 = UIColor(red: 0.8, green: 0, blue: 0, alpha: 0.4).cgColor

		
		let r = self.frame.size.height/4.0
		let mid = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
		
		var bzp = UIBezierPath()
        bzp.addArc(withCenter: CGPoint.zero, radius: r, startAngle: 0, endAngle: CGFloat(endAngle), clockwise: true)
        circle.path = bzp.cgPath
		circle.strokeColor = color1
        circle.fillColor = UIColor.clear.cgColor
		circle.lineWidth = 2
		circle.position = mid
		self.addSublayer(circle)
		
		for _ in 0...10 {
			let line = CAShapeLayer()
			let bzp = UIBezierPath()
            bzp.move(to: CGPoint(x: cos(0)*r*0.8, y: sin(0)*r*0.8))
            bzp.addLine(to: CGPoint(x: cos(0)*r, y: sin(0)*r))
            line.path = bzp.cgPath
			line.strokeColor = color2
			line.lineWidth = 2
			lines.append(line)
			circle.addSublayer(line)
		}
		
		let endcap1 = CAShapeLayer()
		bzp = UIBezierPath()
        bzp.move(to: CGPoint(x: cos(0)*r*0.8, y: sin(0)*r*0.8))
        bzp.addLine(to: CGPoint(x: cos(0)*r, y: sin(0)*r))
        endcap1.path = bzp.cgPath
		endcap1.strokeColor = color1
		endcap1.lineWidth = 2
		circle.addSublayer(endcap1)
		
		let endcap2 = CAShapeLayer()
		bzp = UIBezierPath()
        bzp.move(to: CGPoint(x: cos(endAngle)*Double(r)*0.8, y: sin(endAngle)*Double(r)*0.8))
        bzp.addLine(to: CGPoint(x: cos(endAngle)*Double(r), y: sin(endAngle)*Double(r)))
        endcap2.path = bzp.cgPath
		endcap2.strokeColor = color1
		endcap2.lineWidth = 2
		circle.addSublayer(endcap2)
		
		bzp = UIBezierPath()
        bzp.addArc(withCenter: CGPoint.zero, radius: r + 2, startAngle: 0, endAngle: CGFloat(endAngle*0.2), clockwise: true)
        thickArc.path = bzp.cgPath
		thickArc.strokeColor = color2
        thickArc.fillColor = UIColor.clear.cgColor
		thickArc.lineWidth = 4
		//thickArc.position = mid
		circle.addSublayer(thickArc)

		
	}
	override init() {
		super.init()
		commonInit()
	}
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		commonInit()
	}
	
	@objc func addAnimations() {
		for line in lines {
			let anim = CABasicAnimation(keyPath: "transform.rotation.z")
			anim.toValue = endAngle
			anim.duration = frand()*6.0 + 1.0
            anim.isRemovedOnCompletion = false
			anim.repeatCount = 1e20
			if arc4random_uniform(2) == 0 {
				anim.autoreverses = true
			}
            line.add(anim, forKey: "rot")
		}
		
		let anim = CAKeyframeAnimation(keyPath: "transform.rotation.z")
		anim.values = (0...100).map {
			Int -> Double in
			return frand()*Double.pi*2
		}
        anim.isRemovedOnCompletion = false
		anim.repeatCount = 1e20
		anim.duration = 240
        circle.add(anim, forKey: "rotate")
		


		let anim2 = CABasicAnimation(keyPath: "transform.rotation.z")
		anim2.toValue = Double.pi*0.95
		anim2.duration = 2
        anim2.isRemovedOnCompletion = false
		anim2.repeatCount = 1e20
		anim2.autoreverses = true
        thickArc.add(anim2, forKey: "rot")
	}
}
