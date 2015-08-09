//
//  BezierCurveView.swift
//  CustomAnimations
//
//  Created by Vlas Voloshin on 9/08/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

import UIKit

class BezierCurveView: UIView {

    private
    var shapeLayer: CAShapeLayer!
    var tangentsLayer: CAShapeLayer!
    
    var function: CAMediaTimingFunction? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var strokeColor = UIColor.blackColor() {
        didSet {
            self.shapeLayer.strokeColor = strokeColor.CGColor
            self.tangentsLayer.strokeColor = strokeColor.CGColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    func setupLayers() {
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = self.strokeColor.CGColor
        shapeLayer.fillColor = nil
        shapeLayer.anchorPoint = CGPointZero
        self.layer.addSublayer(shapeLayer)
        
        tangentsLayer = CAShapeLayer()
        tangentsLayer.strokeColor = self.strokeColor.CGColor
        tangentsLayer.fillColor = nil
        tangentsLayer.anchorPoint = CGPointZero
        tangentsLayer.lineDashPattern = [5, 2]
        self.layer.addSublayer(tangentsLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let ownBounds = self.bounds
        self.shapeLayer.bounds = ownBounds
        
        if let function = self.function {
            var controlPoints: [CGPoint] = []
            for i in 0..<4 {
                let valuesArray = UnsafeMutablePointer<Float>.alloc(2)
                function.getControlPointAtIndex(i, values: valuesArray)
                let normalizedPoint = CGPoint(x: CGFloat(valuesArray[0]), y: CGFloat(1.0 - valuesArray[1]))
                let denormalizedPoint = CGPoint(x: normalizedPoint.x * ownBounds.size.width, y: normalizedPoint.y * ownBounds.size.height)
                controlPoints.append(denormalizedPoint)
            }
            
            let curve = UIBezierPath()
            curve.moveToPoint(controlPoints[0])
            curve.addCurveToPoint(controlPoints[3], controlPoint1: controlPoints[1], controlPoint2: controlPoints[2])
            self.shapeLayer.path = curve.CGPath
            
            let tangents = UIBezierPath()
            tangents.moveToPoint(controlPoints[0])
            tangents.addLineToPoint(controlPoints[1])
            tangents.moveToPoint(controlPoints[3])
            tangents.addLineToPoint(controlPoints[2])
            self.tangentsLayer.path = tangents.CGPath
        } else {
            self.shapeLayer.path = nil
            self.tangentsLayer.path = nil
        }
    }
    
}
