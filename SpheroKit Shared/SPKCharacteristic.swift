//
//  Characteristic.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

enum SPKCharacteristic {
    // BLE service
    static let Wake = CBUUID(string: "22bb746f-2bbf-7554-2d6f-726568705327")
    static let TXPower = CBUUID(string: "22bb746f-2bb2-7554-2d6f-726568705327")
    static let AntiDoS = CBUUID(string: "22bb746f-2bbd-7554-2d6f-726568705327")
    
    // RobotControl service
    static let Commands = CBUUID(string: "22bb746f-2ba1-7554-2d6f-726568705327")
    static let Response = CBUUID(string: "22bb746f-2ba6-7554-2d6f-726568705327")
}

