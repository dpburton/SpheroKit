/**
 Sphero Kit
 Robot object
 - Author: Daniel Burton
 - Date: 8/17/19
 */
import Foundation
import CoreBluetooth

/**
 A Sphero robot.
 
 This module handles all of the details of using Bluetooth LE to communicate with the
 robot, giving you a simple to work with api. Communication with the robot is done in non blocking
 asynchronous commands. Results, if any, are retunred with call backs.
 
 You do not directly create SPKRobot objects. Use the SPKManager to get the Sphero Kit robot objects.
 */
public class SPKRobot {
    var responseClosures = [UInt8:([UInt8]) -> Void]()

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
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    func sendCommand(packet: SpheroCommandPacket, response: (([UInt8]) -> Void)? = nil) {
        guard let commandsCharacteristic = commandsCharacteristic else {return}
        let data = packet.dataForPacket()
        if response != nil {
            let delegate = peripheral.delegate as? SPKPeripheralDelegate
            delegate?.responseClosures[packet.commandID] = response
        }
        
        // TODO should move this so it is only done once
        peripheral.setNotifyValue(true, for: commandsCharacteristic)
        peripheral.writeValue(data, for: commandsCharacteristic, type: .withResponse)
    }

    /**
     Sets the color of the main rgb led
     - parameter red: red component
     - parameter red: green component
     - parameter red: blue component
     */
    public func setColor(red: UInt8, green: UInt8, blue: UInt8) {
        sendCommand(packet: SetLEDColorPacket(red: red, green: green, blue: blue, save: true))
    }
    
    /**
     Set the heading of the robot
     
     This allows you to adjust the orientation of Sphero by commanding a new reference heading in degrees, which ranges from 0 to 359.
     You will see the ball respond immediately to this command if stabilization is enabled.
     In FW version 3.10 and later this also clears the maximum value counters for the rate gyro, effectively re-enabling the generation
     of an async message alerting the client to this event.
     - bug: Can't tell that this actually does anything

     - parameter heading: the reference hading in degrees (0-359)
    */
    public func setHeading(heading: Int) {
        sendCommand(packet: UpdateHeadingPacket(heading: UInt16(heading)))
    }
    /**
     This commands Sphero to roll along the provided vector.
     
     Both a speed and a heading are required; the latter is considered relative to the last calibrated direction.
     A state value is also provided. In the CES firmware, this was used to gate the control system to either obey
     the roll vector or ignore it and apply optimal braking to zero speed. Please refer to Appendix C for detailed information.
     The client convention for heading follows the 360 degrees on a circle, relative to the ball: 0 is straight ahead,
     90 is to the right, 180 is back and 270 is to the left. The valid range is 0..359.
     - note: if you set the speed to 0 it changes the direction the robot is facing without moving it
     - parameter heading: The client convention for heading follows the 360 degrees on a circle, relative to the ball: 0 is straight ahead,
     90 is to the right, 180 is back and 270 is to the left. The valid range is 0..359.
     - parameter speed: how fast to roll ;-)
    */
    public func roll(heading: Int, speed: Int) {
        sendCommand(packet: RollCommandPacket(speed: UInt8(speed), heading: UInt16(heading)))
    }
    
    /**
        Turns the back LED on or off. The value does not persist across power cycles
    */
    public func showBackLight(_ showLight: Bool) {
        sendCommand(packet: SetBackLEDBrightnessPacket(brightness: showLight ? 255 : 0))
    }
    
    /**
     Gets the current color of the rgb led
     */
    public func getColor(results: @escaping (_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Void)
    {
        sendCommand(packet: GetLEDColorPacket(), response: {bytes in
            guard (bytes.count > 7) else {return}
            results(bytes[5], bytes[6], bytes[7])
        })
    }
}
