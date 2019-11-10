//
//  SPKRobot.swift
//  SpheroKit
//
//  Created by Daniel Burton on 11/8/19.
//

import Foundation
import CoreBluetooth

public protocol SPKRobot {

    var peripheral:CBPeripheral { get set }

    /**
     Sets the color of the main rgb led
     - parameter red: red component
     - parameter red: green component
     - parameter red: blue component
     */
     func setColor(red: UInt8, green: UInt8, blue: UInt8)

    /**
     Set the heading of the robot

     This allows you to adjust the orientation of Sphero by commanding a new reference heading in degrees, which ranges from 0 to 359.
     You will see the ball respond immediately to this command if stabilization is enabled.
     In FW version 3.10 and later this also clears the maximum value counters for the rate gyro, effectively re-enabling the generation
     of an async message alerting the client to this event.
     - bug: Can't tell that this actually does anything

     - parameter heading: the reference hading in degrees (0-359)
    */
     func setHeading(heading: Int)

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
    func roll(heading: Int, speed: Int)

    /**
        Turns the back LED on or off. The value does not persist across power cycles
    */
    func showBackLight(_ showLight: Bool)

    /**
     Gets the current color of the rgb led
     */
    func getColor(results: @escaping (_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Void)
}

