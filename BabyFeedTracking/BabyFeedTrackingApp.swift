//
//  BabyFeedTrackingApp.swift
//  BabyFeedTracking
//
//  Created by Bhumika Patel on 29/11/24.
//

import SwiftUI

@main
struct BabyFeedTrackingApp: App {
    init() {
           requestNotificationPermissions()
       }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
