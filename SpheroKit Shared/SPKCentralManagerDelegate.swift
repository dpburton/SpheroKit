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
    lazy var peripheralDelegate = SPKPeripheralDelegate()
    
    init(foundPeripheral: @escaping (CBPeripheral) -> Void) {
        self.foundPeripheral = foundPeripheral
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
            central.scanForPeripherals(withServices: [SPKService.RobotControl], options: nil)
        @unknown default:
            print("central.state is \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        foundPeripheral(peripheral)
        // hmm maybe I don't want to connect here
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = peripheralDelegate
        peripheral.discoverServices([SPKService.BLEService, SPKService.RobotControl])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    }
}
