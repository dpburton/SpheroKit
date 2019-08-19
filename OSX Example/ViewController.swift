//
//  ViewController.swift
//  OSX Example
//
//  Created by Daniel Burton on 8/17/19.
//

import Cocoa
import SpheroKit_OSX

class ViewController: NSViewController {
    var robotManager = SPKManager.sharedInstance
    var speed: Int = 0
    var heading: Int = 0

    @IBOutlet weak var connectedCountLabel: NSTextField!
    @IBOutlet weak var redTextField: NSTextField!
    @IBOutlet weak var greenTextField: NSTextField!
    @IBOutlet weak var blueTextField: NSTextField!
    @IBOutlet weak var redSlider: NSSlider!
    @IBOutlet weak var greenSlider: NSSlider!
    @IBOutlet weak var blueSlider: NSSlider!
    @IBOutlet weak var headingSlider: NSSlider!
    @IBOutlet weak var colorWell: NSColorWell!

    @IBAction func headingSliderChanged(_ sender: NSSlider) {
        heading = Int(sender.intValue)
        for robotEntry in robotManager.knownRobots {
            robotEntry.value.roll(heading: heading, speed: speed)
        }

    }
    
    @IBAction func speedSliderChanged(_ sender: NSSlider) {
        speed = Int(sender.intValue)
        for robotEntry in robotManager.knownRobots {
            robotEntry.value.roll(heading: heading, speed: speed)
        }

        
    }
    @IBAction func showBackLightButton(_ sender: NSButton) {
        for robotEntry in robotManager.knownRobots {
            robotEntry.value.showBackLight(sender.state == .on)
        }
    }
    @IBAction func setRed(_ sender: NSSlider) {
        redTextField.cell?.title = String(sender.intValue)
        updateColor()
    }
    
    @IBAction func setBlue(_ sender: NSSlider) {
        blueTextField.cell?.title = String(sender.intValue)
        updateColor()
    }
    
    @IBAction func setGreen(_ sender: NSSlider) {
        greenTextField.cell?.title = String(sender.intValue)
        updateColor()
    }
    
    @IBAction func setColorFromWell(_ sender: NSColorWell) {
        let red = Int32(sender.color.redComponent * 255)
        let green = Int32(sender.color.greenComponent * 255)
        let blue = Int32(sender.color.blueComponent * 255)
        
        redSlider.intValue = red
        greenSlider.intValue = green
        blueSlider.intValue = blue
        redTextField.cell?.title = String(red)
        greenTextField.cell?.title = String(green)
        blueTextField.cell?.title = String(blue)
        updateColor()
    }
    
    func updateColor()  {
        let red = UInt8(redSlider.intValue)
        let green = UInt8(greenSlider.intValue)
        let blue = UInt8(blueSlider.intValue)
        
        colorWell.color = NSColor(deviceRed: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        for robotEntry in robotManager.knownRobots {
            robotEntry.value.setColor(red: red, green: green, blue: blue)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        robotManager.scanForRobots { [weak self] in
            self?.connectedCountLabel.cell?.title = "\(self?.robotManager.knownRobots.count ?? 0)"
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}



