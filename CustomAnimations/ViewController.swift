//
//  ViewController.swift
//  CustomAnimations
//
//  Created by Vlas Voloshin on 9/08/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var animatedView: UIView!
    @IBOutlet private weak var durationSlider: UISlider!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var curveView: BezierCurveView!
    @IBOutlet private weak var standardCurvesTableView: UITableView!
    @IBOutlet private weak var leftConstraint: NSLayoutConstraint!

    @IBOutlet private weak var c1xSlider: UISlider!
    @IBOutlet private weak var c1ySlider: UISlider!
    @IBOutlet private weak var c2xSlider: UISlider!
    @IBOutlet private weak var c2ySlider: UISlider!

    @IBOutlet private weak var c1xLabel: UILabel!
    @IBOutlet private weak var c1yLabel: UILabel!
    @IBOutlet private weak var c2xLabel: UILabel!
    @IBOutlet private weak var c2yLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.durationLabel.text = self.durationFormatter.string(from: self.durationSlider.value as NSNumber)
        self.curveView.function = self.function
        self.applyTimingFunctionOnSliders(self.function)
    }

    // MARK: - Actions

    @IBAction private func playAnimation(_ sender: Any!) {
        let animation = CABasicAnimation(keyPath: "position.x")
        let movement = self.animatedView.superview!.bounds.size.width - self.animatedView.frame.size.width
        animation.byValue = movement
        animation.duration = TimeInterval(self.durationSlider.value)
        animation.timingFunction = self.function
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        self.animatedView.layer.add(animation, forKey: "CustomAnimation")
    }
    
    @IBAction private func resetAnimation(_ sender: Any!) {
        self.animatedView.layer.removeAllAnimations()
    }

    @IBAction private func updateDurationValue(_ sender: UISlider!) {
        self.durationLabel.text = self.durationFormatter.string(from: sender.value as NSNumber)
    }

    @IBAction private func updateControlPointValue(_ sender: UISlider!) {
        guard let sliderIndex = self.controlPointSliders.index(of: sender) else {
            preconditionFailure("Invalid sender!")
        }

        let label = self.controlPointLabels[sliderIndex]
        label.text = self.controlPointFormatter.string(from: sender.value as NSNumber)

        if let selectedIndexPath = self.standardCurvesTableView.indexPathForSelectedRow {
            self.standardCurvesTableView.deselectRow(at: selectedIndexPath, animated: false)
        }

        self.function = self.timingFunctionFromSliders()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.standardTimingFunctions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timingTitle = self.standardTimingFunctions[indexPath.row].title
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = timingTitle

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let functionName = self.standardTimingFunctions[indexPath.row].name
        self.function = CAMediaTimingFunction(name: functionName)
        self.applyTimingFunctionOnSliders(self.function)
    }

    // MARK: - Private
    
    private let durationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.positiveSuffix = " s"
        return formatter
    }()

    private let controlPointFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        return formatter
    }()

    private let standardTimingFunctions: [(title: String, name: String)] = [
        ("Linear", kCAMediaTimingFunctionLinear),
        ("Ease In", kCAMediaTimingFunctionEaseIn),
        ("Ease Out", kCAMediaTimingFunctionEaseOut),
        ("Ease In Out", kCAMediaTimingFunctionEaseInEaseOut),
        ("Default", kCAMediaTimingFunctionDefault)
    ]

    private var controlPointSliders: [UISlider] {
        return [ self.c1xSlider, self.c1ySlider, self.c2xSlider, self.c2ySlider ]
    }

    private var controlPointLabels: [UILabel] {
        return [ self.c1xLabel, self.c1yLabel, self.c2xLabel, self.c2yLabel ]
    }

    private var function = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault) {
        didSet {
            self.curveView.function = self.function
        }
    }

    private func timingFunctionFromSliders() -> CAMediaTimingFunction {
        let points = self.controlPointSliders.map { $0.value }
        return CAMediaTimingFunction(controlPoints: points[0], points[1], points[2], points[3])
    }
    
    private func applyTimingFunctionOnSliders(_ function: CAMediaTimingFunction) {
        let c1Values = UnsafeMutablePointer<Float>.allocate(capacity: 2)
        function.getControlPoint(at: 1, values: c1Values)
        let c2Values = UnsafeMutablePointer<Float>.allocate(capacity: 2)
        function.getControlPoint(at: 2, values: c2Values)

        let points = [ c1Values[0], c1Values[1], c2Values[0], c2Values[1] ]

        for (point, slider) in zip(points, self.controlPointSliders) {
            slider.value = point
        }

        for (point, label) in zip(points, self.controlPointLabels) {
            label.text = self.controlPointFormatter.string(from: point as NSNumber)
        }
    }

}

