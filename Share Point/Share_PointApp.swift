//
//  Share_PointApp.swift
//  Share Point
//
//  Created by Dibyo sarkar on 9/1/25.
//

import SwiftUI
import Firebase

@main
struct Share_PointApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
