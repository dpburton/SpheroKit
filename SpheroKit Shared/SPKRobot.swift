//
//  BB8.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

public class SPKRobot {
    var peripheral:CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
}
