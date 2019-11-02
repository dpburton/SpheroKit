//
//  HostingController.swift
//  WatchOS Example WatchKit Extension
//
//  Created by Daniel Burton on 10/31/19.
//

import WatchKit
import Foundation
import SwiftUI
import SpheroKit_WatchOS

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
        var robotManager = SPKManager.sharedInstance

        return ContentView()
    }

}
