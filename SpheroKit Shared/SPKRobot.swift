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
    var _controlService: CBService?
    var controlService: CBService? {
        get {
            if _controlService == nil {
                _controlService = peripheral.serviceFor(SPKService.RobotControl)
            }
            return _controlService
        }
    }
    var _commandsCharacteristic: CBCharacteristic?
    var commandsCharacteristic:CBCharacteristic? {
        get {
            if _commandsCharacteristic == nil {
                _commandsCharacteristic = controlService?.characteristicFor(SPKCharacteristic.Command)
            }
            return _commandsCharacteristic
        }
    }
    var packetSeqNum: UInt8 = 0
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    func sendCommand(packet: SpheroCommandPacket) {
        guard let commandsCharacteristic = commandsCharacteristic else {return}
        let data = packet.dataForPacket(sequenceNumber: packetSeqNum)
        packetSeqNum += 1
        
        // TODO should move this so it is only done once
        peripheral.setNotifyValue(true, for: commandsCharacteristic)
        peripheral.writeValue(data, for: commandsCharacteristic, type: .withResponse)
    }

    
    public func setColor(red: UInt8, green: UInt8, blue: UInt8) {
        sendCommand(packet: SetLEDColorPacket(red: red, green: green, blue: blue, save: true))
    }
    
    public func setHeading(heading: Int) {
        sendCommand(packet: UpdateHeadingPacket(heading: UInt16(heading)))
    }
    
    public func roll(heading: Int, speed: Int) {
        sendCommand(packet: RollCommandPacket(speed: UInt8(speed), heading: UInt16(heading)))
    }
    
    public func showBackLight(_ showLight: Bool) {
        sendCommand(packet: SetBackLEDBrightnessPacket(brightness: showLight ? 255 : 0))
    }
}
