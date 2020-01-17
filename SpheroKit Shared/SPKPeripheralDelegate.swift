//
//  SKPeripheralDelegate.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

class SPKPeripheralDelegate: NSObject, CBPeripheralDelegate {
    let responseCommandIndex = 3
    
    var responseClosures = [UInt8:([UInt8]) -> Void]()
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            switch service.uuid {
            case SPKService.BLEService:
                print("Found BLE service", service.debugDescription)
                peripheral.discoverCharacteristics([SPKCharacteristic.AntiDoS, SPKCharacteristic.TXPower, SPKCharacteristic.Wake], for: service)
            case SPKService.RobotControl:
                print("Found robot control service", service.debugDescription)
                peripheral.discoverCharacteristics([SPKCharacteristic.Command, SPKCharacteristic.Response], for: service)
            case SPKService.APIv2ControlService:
                print("Found APIv2 Control service", service.debugDescription)
                peripheral.discoverCharacteristics([SPKCharacteristic.apiV2Characteristic, SPKCharacteristic.apiV2Characteristic2], for: service)
            case SPKService.NordicDfuService:
                print("Found NordicDfuService Control service", service.debugDescription)
                peripheral.discoverCharacteristics([SPKCharacteristic.dfuControlCharacteristic, SPKCharacteristic.dfuInfoCharacteristic, SPKCharacteristic.antiDoSCharacteristic, SPKCharacteristic.subsCharacteristic], for: service)
            case SPKService.BatteryService:
                print("Found battery service")
            default:
                print("this is not a service we are looking for", service.debugDescription)
                continue
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        switch service.uuid {
        case SPKService.BLEService:
            print("Found \(service.characteristics?.count ?? 0) BB-8 BLE service characteristics: ",service.characteristics.debugDescription)
            guard let antiDoS = service.characteristicFor(SPKCharacteristic.AntiDoS) else {return}
                peripheral.writeValue("011i3".data(using: .ascii)!, for: antiDoS, type: .withResponse)
        case SPKService.RobotControl:
            print("Found \(service.characteristics?.count ?? 0) BB-8 robot control service characteristics:",service.characteristics.debugDescription)
            guard let command = service.characteristicFor(SPKCharacteristic.Response) else {return}
            peripheral.setNotifyValue(true, for: command)
        case SPKService.NordicDfuService:
            print("Found \(service.characteristics?.count ?? 0) BB-9E Nordic Dfu Service characteristics:", service.characteristics.debugDescription)
            if let antiDoS = service.characteristicFor(SPKCharacteristic.antiDoSCharacteristic) {
                peripheral.writeValue("usetheforce...band".data(using: .ascii)!, for: antiDoS, type: .withResponse)
            }
        case SPKService.APIv2ControlService:
            print("Found \(service.characteristics?.count ?? 0) BB-9E APIv2 control service characteristics:", service.characteristics.debugDescription)
        default:
            print("This is not the service we are looking for", service.characteristics.debugDescription)
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
        case SPKCharacteristic.antiDoSCharacteristic:
            print("Sent the usetheforce...band antidos command")
            guard let service = peripheral.serviceFor(SPKService.APIv2ControlService),
                let wake = service.characteristicFor(SPKCharacteristic.apiV2Characteristic) else {return}
            peripheral.writeValue(Data([1]), for: wake, type: .withResponse)
            break
        case SPKCharacteristic.apiV2Characteristic:
            print("wrote to the SPKCharacteristic.apiV2Characteristic")
        default:
            break
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else { return }
        let bytes = [UInt8](value)
        if bytes.count > responseCommandIndex {
            let command = bytes[responseCommandIndex]
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
