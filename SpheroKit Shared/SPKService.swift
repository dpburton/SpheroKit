//
//  Services.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

enum SPKService {
    static let BLEService = CBUUID(string: "22BB746F-2BB0-7554-2D6F-726568705327")
    static let RobotControl = CBUUID(string: "22bb746f-2ba0-7554-2d6f-726568705327")
    static let APIv2ControlService = CBUUID(string: "00010001-574f-4f20-5370-6865726f2121")
    static let NordicDfuService = CBUUID(string: "00020001-574f-4f20-5370-6865726f2121")
    static let BatteryService = CBUUID(string:"180f")
}
