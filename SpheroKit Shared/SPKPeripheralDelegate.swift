//
//  SKPeripheralDelegate.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

class SPKPeripheralDelegate: NSObject, CBPeripheralDelegate {
    // TODO need to add the response format here. 
    let responseSeqIndex = 3
    
    var responseClosures = [UInt8:([UInt8]) -> Void]()
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service.debugDescription)
            switch service.uuid {
            case SPKService.BLEService:
                peripheral.discoverCharacteristics([SPKCharacteristic.AntiDoS, SPKCharacteristic.TXPower, SPKCharacteristic.Wake], for: service)
            case SPKService.RobotControl:
                peripheral.discoverCharacteristics([SPKCharacteristic.Command, SPKCharacteristic.Response], for: service)
            case SPKService.APIv2ControlService:
                peripheral.discoverCharacteristics([SPKCharacteristic.apiV2Characteristic, SPKCharacteristic.apiV2Characteristic2, SPKCharacteristic.dfuControlCharacteristic, SPKCharacteristic.dfuInfoCharacteristic, SPKCharacteristic.antiDoSCharacteristic, SPKCharacteristic.subsCharacteristic], for: service)
            default:
                // this is a service we aren't using
                continue
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print(service.characteristics.debugDescription)
        switch service.uuid {
        case SPKService.BLEService:
            guard let antiDoS = service.characteristicFor(SPKCharacteristic.AntiDoS) else {return}
                peripheral.writeValue("011i3".data(using: .ascii)!, for: antiDoS, type: .withResponse)
        case SPKService.RobotControl:
            guard let command = service.characteristicFor(SPKCharacteristic.Response) else {return}
            peripheral.setNotifyValue(true, for: command)
        case SPKService.APIv2ControlService:
            if let antiDoS = service.characteristicFor(SPKCharacteristic.antiDoSCharacteristic) {
                peripheral.writeValue("usetheforce...band".data(using: .ascii)!, for: antiDoS, type: .withResponse)
            }
        default:
            if let antiDoS = service.characteristicFor(SPKCharacteristic.antiDoSCharacteristic) {
                peripheral.writeValue("usetheforce...band".data(using: .ascii)!, for: antiDoS, type: .withResponse)
            }
            print(service.characteristics.debugDescription)
            break
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case SPKCharacteristic.AntiDoS:
            guard let service = peripheral.serviceFor(SPKService.BLEService),
                let txPower = service.characteristicFor(SPKCharacteristic.TXPower) else {return}
            peripheral.writeValue(Data([7]), for: txPower, type: .withResponse)
        case SPKCharacteristic.TXPower:
            guard let service = peripheral.serviceFor(SPKService.BLEService),
                let wake = service.characteristicFor(SPKCharacteristic.Wake) else {return}
            peripheral.writeValue(Data([1]), for: wake, type: .withResponse)
        case SPKCharacteristic.Wake:
            // at this point we shoud have a good connection to the robot
            break
        case SPKCharacteristic.Command:
            break
        default:
            break
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // TODO need to verify the packet should be ffff seq command length data checksum
        guard let value = characteristic.value else { return }
        let bytes = [UInt8](value)
        if bytes.count > responseSeqIndex {
            let command = bytes[responseSeqIndex]
            if let closure = responseClosures[command] {
                closure(bytes)
            }
        }
        let v = value as NSData
        print(v.description)
    }
}

extension CBService {
    func characteristicFor(_ uuid: CBUUID) -> CBCharacteristic? {
        return characteristics?.first(where: {$0.uuid == uuid})
    }
}

extension CBPeripheral {
    func serviceFor(_ uuid: CBUUID) -> CBService? {
        return services?.first(where: {$0.uuid == uuid})
    }

}
