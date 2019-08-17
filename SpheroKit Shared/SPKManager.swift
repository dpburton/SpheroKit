//
//  SPKManager.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

public class SPKManager {
    var knownRobotsChanged: (() -> Void)?
    public var knownRobots = [UUID:SPKRobot]()
    lazy var centralManagerDelegate = SPKCentralManagerDelegate(foundPeripheral: {[weak self] peripheral in
        
            var robot = SPKRobot(peripheral: peripheral)
            self?.knownRobots[robot.peripheral.identifier] = robot
            self?.knownRobotsChanged?()
        })
    lazy var centralManager = CBCentralManager(delegate: centralManagerDelegate, queue: nil)
    
    public static let sharedInstance = SPKManager()

    public func scanForRobots(knownRobotsChanged: @escaping () -> Void )
    {
        self.knownRobotsChanged = knownRobotsChanged
        _ = centralManager
    }
    
    func foundRobot(peripheral: CBPeripheral) {
        let robot = SPKRobot(peripheral: peripheral)
        knownRobots[robot.peripheral.identifier] = robot
        knownRobotsChanged?()
    }
}
