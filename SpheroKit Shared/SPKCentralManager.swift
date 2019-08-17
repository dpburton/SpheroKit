//
//  SPKCentralManager.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

class SPKCentralManager {
    lazy var delegate = SPKCentralManagerDelegate()
    lazy var centralManager = CBCentralManager(delegate: delegate, queue: nil)
    static let sharedInstance = SPKCentralManager()

}
