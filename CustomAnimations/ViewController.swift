//
//  ViewController.swift
//  CustomAnimations
//
//  Created by Vlas Voloshin on 9/08/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var animatedView: UIView!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var curveView: BezierCurveView!
    @IBOutlet weak var standardCurvesTableView: UITableView!
    
    var function: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault) {
        didSet {
            curveView.function = function
        }
    }
    
    let durationFormatter = {
        (Void) -> NSNumberFormatter in
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.positiveSuffix = " s"
        return formatter;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        durationLabel.text = self.durationFormatter.stringFromNumber(self.durationSlider.value)
        curveView.function = self.function
        applyTimingFunctionOnSliders(self.function)
    }
    
    func animate() {
        let animation = CABasicAnimation(keyPath: "position.x")
        let movement = self.animatedView.superview!.bounds.size.width - self.animatedView.frame.size.width
        animation.byValue = movement
        animation.duration = NSTimeInterval(self.durationSlider.value)
        animation.timingFunction = self.function
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        self.animatedView.layer.addAnimation(animation, forKey: "CustomAnimation")
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        animate()
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        self.animatedView.layer.removeAllAnimations()
    }

    @IBAction func durationSliderValueChanged(sender: UISlider) {
        durationLabel.text = self.durationFormatter.stringFromNumber(sender.value)
    }
    
    // MARK: Control points
    
    @IBOutlet weak var c1xSlider: UISlider!
    @IBOutlet weak var c1ySlider: UISlider!
    @IBOutlet weak var c2xSlider: UISlider!
    @IBOutlet weak var c2ySlider: UISlider!
    @IBOutlet weak var c1xLabel: UILabel!
    @IBOutlet weak var c1yLabel: UILabel!
    @IBOutlet weak var c2xLabel: UILabel!
    @IBOutlet weak var c2yLabel: UILabel!
    
    let controlPointFormatter = {
        (Void) -> NSNumberFormatter in
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        return formatter;
    }()
    
    @IBAction func controlPointSliderValueChanged(sender: UISlider) {
        let text = controlPointFormatter.stringFromNumber(sender.value)
        switch sender {
        case c1xSlider:
            c1xLabel.text = text
        case c1ySlider:
            c1yLabel.text = text
        case c2xSlider:
            c2xLabel.text = text
        case c2ySlider:
            c2yLabel.text = text
        default:
            assertionFailure("Invalid slider")
        }
        
        if let selectedIndexPath = self.standardCurvesTableView.indexPathForSelectedRow() {
            self.standardCurvesTableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
        
        self.function = timingFunctionFromSliders()
    }
    
    func timingFunctionFromSliders() -> CAMediaTimingFunction {
        let points = [c1xSlider, c1ySlider, c2xSlider, c2ySlider].map({ $0.value })
        return CAMediaTimingFunction(controlPoints: points[0], points[1], points[2], points[3])
    }
    
    func applyTimingFunctionOnSliders(function: CAMediaTimingFunction) {
        let c1Values = UnsafeMutablePointer<Float>.alloc(2)
        function.getControlPointAtIndex(1, values: c1Values)
        let c2Values = UnsafeMutablePointer<Float>.alloc(2)
        function.getControlPointAtIndex(2, values: c2Values)
        let points = [ c1Values[0], c1Values[1], c2Values[0], c2Values[1] ]
        
        let sliders = [ c1xSlider, c1ySlider, c2xSlider, c2ySlider ]
        let labels = [ c1xLabel, c1yLabel, c2xLabel, c2yLabel ]
        for i in 0..<points.count {
            sliders[i].value = points[i]
            labels[i].text = controlPointFormatter.stringFromNumber(points[i])
        }
    }
    
    // MARK: Standard timings

    let standardTimingFunctions = [ ("Linear", kCAMediaTimingFunctionLinear), ("Ease In", kCAMediaTimingFunctionEaseIn), ("Ease Out", kCAMediaTimingFunctionEaseOut), ("Ease In Out", kCAMediaTimingFunctionEaseInEaseOut), ("Default", kCAMediaTimingFunctionDefault) ]
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return standardTimingFunctions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let timingTitle = standardTimingFunctions[indexPath.row].0
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = timingTitle
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let timingValue = standardTimingFunctions[indexPath.row].1
        let function = CAMediaTimingFunction(name: timingValue)
        self.function = function
        applyTimingFunctionOnSliders(function)
    }
}

