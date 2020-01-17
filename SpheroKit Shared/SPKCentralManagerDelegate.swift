//
//  SKCentralManagerDelegate.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

class SPKCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    
    var knownRobots = [UUID:SPKRobot]()
    var foundPeripheral: ((CBPeripheral) -> Void)
    var connectedPeripheral: ((CBPeripheral) -> Void)
    var disconnectedPeripheral: ((CBPeripheral) -> Void)
    lazy var peripheralDelegate = SPKPeripheralDelegate()
    
    init(foundPeripheral: @escaping (CBPeripheral) -> Void, connectedPeripheral: (@escaping (CBPeripheral) -> Void), disconnectedPeripheral: @escaping (CBPeripheral) -> Void) {
        self.foundPeripheral = foundPeripheral
        self.connectedPeripheral = connectedPeripheral
        self.disconnectedPeripheral = disconnectedPeripheral
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            central.stopScan()
            break
        case .poweredOn:
            central.scanForPeripherals(withServices: [SPKService.RobotControl, SPKService.APIv2ControlService, SPKService.NordicDfuService], options: nil)
        @unknown default:
            print("central.state is \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        foundPeripheral(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = peripheralDelegate
        peripheral.discoverServices([SPKService.BLEService, SPKService.RobotControl, SPKService.APIv2ControlService, SPKService.NordicDfuService, SPKService.BatteryService])
        print("Connected to ", peripheral)
        connectedPeripheral(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected from \(peripheral.debugDescription) error:\(error?.localizedDescription ?? "unknown")")
        disconnectedPeripheral(peripheral)
    }
}
