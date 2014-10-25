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
	let endAngle = M_PI*1.2
	func commonInit() {
		let color1 = UIColor(white: 0.5, alpha: 0.6).CGColor
		let color2 = UIColor(red: 0.8, green: 0, blue: 0, alpha: 0.4).CGColor

		
		let r = self.frame.size.height/4.0
		let mid = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
		
		var bzp = UIBezierPath()
		bzp.addArcWithCenter(CGPointZero, radius: r, startAngle: 0, endAngle: CGFloat(endAngle), clockwise: true)
		circle.path = bzp.CGPath
		circle.strokeColor = color1
		circle.fillColor = UIColor.clearColor().CGColor
		circle.lineWidth = 2
		circle.position = mid
		self.addSublayer(circle)
		
		for index in 0...10 {
			let line = CAShapeLayer()
			let bzp = UIBezierPath()
			bzp.moveToPoint(CGPoint(x: cos(0)*r*0.8, y: sin(0)*r*0.8))
			bzp.addLineToPoint(CGPoint(x: cos(0)*r, y: sin(0)*r))
			line.path = bzp.CGPath
			line.strokeColor = color2
			line.lineWidth = 2
			lines.append(line)
			circle.addSublayer(line)
		}
		
		let endcap1 = CAShapeLayer()
		bzp = UIBezierPath()
		bzp.moveToPoint(CGPoint(x: cos(0)*r*0.8, y: sin(0)*r*0.8))
		bzp.addLineToPoint(CGPoint(x: cos(0)*r, y: sin(0)*r))
		endcap1.path = bzp.CGPath
		endcap1.strokeColor = color1
		endcap1.lineWidth = 2
		circle.addSublayer(endcap1)
		
		let endcap2 = CAShapeLayer()
		bzp = UIBezierPath()
		bzp.moveToPoint(CGPoint(x: cos(endAngle)*Double(r)*0.8, y: sin(endAngle)*Double(r)*0.8))
		bzp.addLineToPoint(CGPoint(x: cos(endAngle)*Double(r), y: sin(endAngle)*Double(r)))
		endcap2.path = bzp.CGPath
		endcap2.strokeColor = color1
		endcap2.lineWidth = 2
		circle.addSublayer(endcap2)
		
		bzp = UIBezierPath()
		bzp.addArcWithCenter(CGPointZero, radius: r + 2, startAngle: 0, endAngle: CGFloat(endAngle*0.2), clockwise: true)
		thickArc.path = bzp.CGPath
		thickArc.strokeColor = color2
		thickArc.fillColor = UIColor.clearColor().CGColor
		thickArc.lineWidth = 4
		//thickArc.position = mid
		circle.addSublayer(thickArc)

		
	}
	init(frame: CGRect) {
		super.init()
		self.frame = frame
		commonInit()
	}
	override init() {
		super.init()
		commonInit()
	}
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func addAnimations() {
		for line in lines {
			let anim = CABasicAnimation(keyPath: "transform.rotation.z")
			anim.toValue = endAngle
			anim.duration = frand()*6.0 + 1.0
			anim.removedOnCompletion = false
			anim.repeatCount = 1e100
			if arc4random_uniform(2) == 0 {
				anim.autoreverses = true
			}
			line.addAnimation(anim, forKey: "rot")
		}
		
		let anim = CAKeyframeAnimation(keyPath: "transform.rotation.z")
		anim.values = (0...100).map {
			Int -> Double in
			return frand()*M_PI*2
		}
		anim.removedOnCompletion = false
		anim.repeatCount = 1e100
		anim.duration = 240
		circle.addAnimation(anim, forKey: "rotate")
		


		let anim2 = CABasicAnimation(keyPath: "transform.rotation.z")
		anim2.toValue = M_PI*0.95
		anim2.duration = 2
		anim2.removedOnCompletion = false
		anim2.repeatCount = 1e100
		anim2.autoreverses = true
		thickArc.addAnimation(anim2, forKey: "rot")
	}
}