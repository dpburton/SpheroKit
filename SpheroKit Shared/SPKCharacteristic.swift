//
//  Characteristic.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
// with help from https://github.com/igbopie/spherov2.js

import Foundation
import CoreBluetooth

enum SPKCharacteristic {
    // BLE service
    static let Wake = CBUUID(string: "22bb746f-2bbf-7554-2d6f-726568705327")
    static let TXPower = CBUUID(string: "22bb746f-2bb2-7554-2d6f-726568705327")
    static let AntiDoS = CBUUID(string: "22bb746f-2bbd-7554-2d6f-726568705327")
    
    // RobotControl service
    static let Command = CBUUID(string: "22bb746f-2ba1-7554-2d6f-726568705327")
    static let Response = CBUUID(string: "22bb746f-2ba6-7554-2d6f-726568705327")

    // v2 Characteristic
    static let apiV2Characteristic =  CBUUID(string: "00010002-574f-4f20-5370-6865726f2121")
    static let dfuControlCharacteristic =  CBUUID(string: "00020002-574f-4f20-5370-6865726f2121")
    static let dfuInfoCharacteristic =  CBUUID(string: "00020004-574f-4f20-5370-6865726f2121")
    static let antiDoSCharacteristic =  CBUUID(string: "00020005-574f-4f20-5370-6865726f2121")
    static let subsCharacteristic =  CBUUID(string: "00020003-574f-4f20-53706865726f2121")
}

