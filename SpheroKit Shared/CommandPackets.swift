//
//  CommandPackets.swift
//  SpheroKit
//
//  Created by Daniel Burton on 8/17/19.
//

import Foundation
import CoreBluetooth

public protocol CommandPacket {
    var answer: Bool { get }
    var resetTimeout: Bool { get }
    var deviceID: UInt8 { get }
    var commandID: UInt8 { get }
    var payload: Data? { get }
}

extension CommandPacket {
    public var answer: Bool {
        return true
    }
    
    public var resetTimeout: Bool {
        return true
    }
    
    public var sop2: UInt8 {
        var value: UInt8 = 0b11111100
        if answer {
            value |= 1 << 0
        }
        if resetTimeout {
            value |= 1 << 1
        }
        
        return value
    }
    
    internal func dataForPacket(sequenceNumber: UInt8 = 0) -> Data {
        let payloadLength = payload?.count ?? 0
        var zero: UInt8 = 0
        var data = Data(bytes: &zero, count: 6)
        
        data[0] = 0b11111111
        data[1] = sop2
        data[2] = deviceID
        data[3] = commandID
        data[4] = commandID
        data[5] = UInt8(payloadLength + 1)
        
        if let payload = payload {
            data.append(payload)
        }
        
        let checksumTarget = data[2 ..< data.count]
        
        var checksum: UInt8 = 0
        for byte in checksumTarget {
            checksum = checksum &+ byte
        }
        checksum = ~checksum
        
        data.append(Data([checksum]))
        
        return data
    }
}

public protocol CoreCommandPacket: CommandPacket {}

extension CoreCommandPacket {
    public var deviceID: UInt8 {
        return 0x00
    }
}

public protocol SpheroCommandPacket: CommandPacket {}

extension SpheroCommandPacket {
    public var deviceID: UInt8 {
        return 0x02
    }
}

struct UpdateHeadingPacket: SpheroCommandPacket {
    let commandID: UInt8 = 0x01
    
    var heading: UInt16
    init(heading: UInt16) {
        self.heading = heading
    }
    
    var payload: Data? {
        let clampedHeading = (heading % 360)
        let headingLeft = UInt8((clampedHeading >> 8) & 0xff)
        let headingRight = UInt8(clampedHeading & 0xff)
        
        return Data([headingLeft, headingRight])
    }
}

struct SetBackLEDBrightnessPacket: SpheroCommandPacket {
    let commandID: UInt8 = 0x21
    
    var brightness: UInt8
    
    init(brightness: UInt8) {
        self.brightness = brightness
    }
    
    var payload: Data? {
        let data = Data([brightness])
        return data
    }
}

struct RollCommandPacket: SpheroCommandPacket {
    let commandID: UInt8 = 0x30
    
    var speed: UInt8
    var heading: UInt16
    var state: UInt8
    
    init(speed: UInt8, heading: UInt16, state: UInt8 = 1) {
        self.speed = speed
        self.heading = heading
        self.state = state
    }
    
    var payload: Data? {
        let clampedHeading = (heading % 360)
        let headingLeft = UInt8((clampedHeading >> 8) & 0xff)
        let headingRight = UInt8(clampedHeading & 0xff)
        
        return Data([speed, headingLeft, headingRight, state])
    }
}

public struct SetLEDColorPacket: SpheroCommandPacket {
    public let commandID: UInt8 = 0x20
    
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8
    public var save: Bool
    
    public init(red: UInt8, green: UInt8, blue: UInt8, save: Bool = false) {
        self.red = red
        self.green = green
        self.blue = blue
        self.save = save
    }
    
    public var payload: Data? {
        let data = Data([red, green, blue, save ? 1 : 0])
        return data
    }
}

public struct GetLEDColorPacket: SpheroCommandPacket {
    public let commandID: UInt8 = 0x22
    public var payload: Data?
    
}

extension CBPeripheral {
    var controlService: CBService? {
        get {
            return serviceFor(SPKService.RobotControl)
        }
    }
    var commandsCharacteristic:CBCharacteristic? {
        get {
            return controlService?.characteristicFor(SPKCharacteristic.Command)
        }
    }

    func sendCommand(packet: SpheroCommandPacket, sequenceNumber: UInt8 = 0) {
        guard let commandsCharacteristic = commandsCharacteristic else {return}
        let data = packet.dataForPacket(sequenceNumber: sequenceNumber)

        // TODO should move this so it is only done once
        setNotifyValue(true, for: commandsCharacteristic)
        writeValue(data, for: commandsCharacteristic, type: .withResponse)
    }
}
