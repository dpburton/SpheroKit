//
//  InterfaceController.swift
//  BB-9E Remote WatchKit Extension
//
//  Created by Daniel Burton on 11/1/19.
//

import WatchKit
import Foundation
import SpheroKit_WatchOS

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var robotCount: WKInterfaceLabel!

    var robotManager = SPKManager.sharedInstance

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        SPKManager.sharedInstance.scanForRobots {[weak self] in
            self?.robotCount.setText("\(self?.robotManager.knownRobots.count ?? 0)")
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        SPKManager.sharedInstance.stopScanning()
    }

}
