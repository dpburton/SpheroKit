//
//  SPKManager.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

/**
 Sphero Kit Manager
 
 Use the sharedInstance rather than creating an object of this class
 This class is used to get a list of known robots
 */
public class SPKManager {
    /// use this instead of creating your own instance of this class
    public static let sharedInstance = SPKManager()

    /// a dictionary of known Sphero Kit robots
    public var knownRobots = [UUID:SPKRobot]()

    var knownRobotsChanged: (() -> Void)?
    lazy var centralManagerDelegate = SPKCentralManagerDelegate(
        foundPeripheral: {[weak self] peripheral in self?.foundPeriferal(peripheral)},
        connectedPeripheral: {[weak self] peripheral in self?.connectedPeripheral(peripheral)},
        disconnectedPeripheral: {[weak self] peripheral in self?.disconnectedPeripheral(peripheral)})

    lazy var centralManager = CBCentralManager(delegate: centralManagerDelegate, queue: nil)

    private func foundPeriferal(_ peripheral: CBPeripheral) {
        let robot = peripheral.serviceFor(SPKService.RobotControl) == nil ? SPKRobotV2(peripheral: peripheral) as SPKRobot : SPKRobotV1(peripheral: peripheral) as SPKRobot
            self.knownRobots[robot.peripheral.identifier] = robot
            self.knownRobotsChanged?()
    }

    private func connectedPeripheral(_ peripheral: CBPeripheral) {
        knownRobots[peripheral.identifier]?.connected = true
    }

    private func disconnectedPeripheral(_ peripheral: CBPeripheral) {
        knownRobots[peripheral.identifier]?.connected = false
    }

    /**
     Until you scan for robots the list of known robots will be empty
     - parameter knownRobotsChanged: this is called when a robot is added or removed from the list of known robots
    */
    public func scanForRobots(knownRobotsChanged: @escaping () -> Void )
    {
        self.knownRobotsChanged = knownRobotsChanged
        _ = centralManager
    }

    public func connectToRobot(_ robot: SPKRobot)
    {
        if !robot.connected {
            centralManager.connect(robot.peripheral)
        }
    }
    /**
        Call when you no longer need to find new robots
     */
    public func stopScanning() {
        centralManager.stopScan()
    }
    
//    func foundRobot(peripheral: CBPeripheral) {
//        let robot = SPKRobotV1(peripheral: peripheral)
//        knownRobots[robot.peripheral.identifier] = robot
//        knownRobotsChanged?()
//    }
}
