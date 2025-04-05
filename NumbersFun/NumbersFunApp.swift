//
//  NumbersFunApp.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 5.03.25.
//

import SwiftUI

@main
struct NumbersFunApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasLaunchedBefore {
                ContentView()
            } else {
                RootView()
            }
        }
    }
}
