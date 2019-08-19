//
//  ViewController.swift
//  iOS Example
//
//  Created by Daniel Burton on 8/17/19.
//

import UIKit
import SpheroKit_iOS

class ViewController: UIViewController {
    var robotManager = SPKManager.sharedInstance
    var red: UInt8 = 0
    var green: UInt8 = 0
    var blue: UInt8 = 0
    var heading = 0
    var speed = 0
    
    
    @IBOutlet var robotCountLabel: UILabel!
    @IBOutlet weak var backlightSwitch: UISwitch!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var headingSlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        robotManager.scanForRobots { [weak self] in
            self?.robotCountLabel.text = "\(self?.robotManager.knownRobots.count ?? 0)"
    }
    }

    @IBAction func redSliderChanged(_ sender: UISlider) {
        red = UInt8(sender.value)
        updateColor()
    }
    
    @IBAction func greenSliderChanged(_ sender: UISlider) {
        green = UInt8(sender.value)
        updateColor()
    }
    
    @IBAction func blueSliderChanged(_ sender: UISlider) {
        blue = UInt8(sender.value)
        updateColor()
    }
    
    @IBAction func backlightChanged(_ sender: UISwitch) {
        for robotEntry in robotManager.knownRobots {
            robotEntry.value.showBackLight(sender.isOn)
        }
    }
    
    @IBAction func headingSliderChanged(_ sender: UISlider) {
        heading = Int(sender.value)
        for robotEntry in robotManager.knownRobots {
            robotEntry.value.roll(heading: heading, speed: speed)
        }

    }
    
    @IBAction func speedSliderChanged(_ sender: UISlider) {
        speed = Int(sender.value)
        for robotEntry in robotManager.knownRobots {
            robotEntry.value.roll(heading: heading, speed: speed)
        }
    }
    
    
    func updateColor() {
        for robotEntry in robotManager.knownRobots {
            robotEntry.value.setColor(red: red, green: green, blue: blue)
        }
    }
    
    
    
}

