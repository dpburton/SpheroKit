//
//  ViewController.swift
//  OSX Example
//
//  Created by Daniel Burton on 8/17/19.
//

import Cocoa
import SpheroKit_OSX

class ViewController: NSViewController {
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
        
    }
    
    @IBAction func speedSliderChanged(_ sender: NSSlider) {
        
    }
    @IBAction func showBackLightButton(_ sender: NSButton) {
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
        colorWell.color = NSColor(deviceRed: CGFloat(redSlider.intValue) / 255.0, green: CGFloat(greenSlider.intValue) / 255.0, blue: CGFloat(blueSlider.intValue) / 255.0, alpha: 1.0)
        
    }


    var robotManager = SPKManager.sharedInstance
    
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



