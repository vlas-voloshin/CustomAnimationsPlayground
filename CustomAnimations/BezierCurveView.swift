//
//  BezierCurveView.swift
//  CustomAnimations
//
//  Created by Vlas Voloshin on 9/08/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

import UIKit

final class BezierCurveView: UIView {

    var function: CAMediaTimingFunction? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var strokeColor = UIColor.black {
        didSet {
            self.shapeLayer.strokeColor = self.strokeColor.cgColor
            self.tangentsLayer.strokeColor = self.strokeColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let ownBounds = self.bounds
        self.shapeLayer.bounds = ownBounds
        self.tangentsLayer.bounds = ownBounds
        
        if let function = self.function {
            let controlPoints = (0..<4).map { (index: Int) -> CGPoint in
                let valuesArray = UnsafeMutablePointer<Float>.allocate(capacity: 2)
                function.getControlPoint(at: index, values: valuesArray)

                let normalizedPoint = CGPoint(x: CGFloat(valuesArray[0]),
                                              y: CGFloat(1 - valuesArray[1]))
                let denormalizedPoint = CGPoint(x: normalizedPoint.x * ownBounds.size.width,
                                                y: normalizedPoint.y * ownBounds.size.height)

                return denormalizedPoint
            }
            
            let curve = UIBezierPath()
            curve.move(to: controlPoints[0])
            curve.addCurve(to: controlPoints[3], controlPoint1: controlPoints[1], controlPoint2: controlPoints[2])
            self.shapeLayer.path = curve.cgPath
            
            let tangents = UIBezierPath()
            tangents.move(to: controlPoints[0])
            tangents.addLine(to: controlPoints[1])
            tangents.move(to: controlPoints[3])
            tangents.addLine(to: controlPoints[2])
            self.tangentsLayer.path = tangents.cgPath
        } else {
            self.shapeLayer.path = nil
            self.tangentsLayer.path = nil
        }
    }

    // MARK: - Private

    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = nil
        shapeLayer.anchorPoint = CGPoint.zero
        return shapeLayer
    }()

    private let tangentsLayer: CAShapeLayer = {
        let tangentsLayer = CAShapeLayer()
        tangentsLayer.fillColor = nil
        tangentsLayer.anchorPoint = CGPoint.zero
        tangentsLayer.lineDashPattern = [5, 2]
        return tangentsLayer
    }()

    private func commonInit() {
        self.shapeLayer.strokeColor = self.strokeColor.cgColor
        self.layer.addSublayer(self.shapeLayer)

        self.layer.addSublayer(self.tangentsLayer)
        self.tangentsLayer.strokeColor = self.strokeColor.cgColor
    }
    
}
