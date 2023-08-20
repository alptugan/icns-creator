//
//  icns_creatorApp.swift
//  icns creator
//
//  Created by alp tugan on 10.08.2023.
//

import SwiftUI

@available(macOS 13.0, *)
@main
struct icns_creatorApp: App {
    var body: some Scene {
        
        WindowGroup {
            let w:CGFloat = 300
            let h:CGFloat = 300
            
            ContentView()
                .frame(minWidth: w,maxWidth: w,minHeight: h,maxHeight: h)
                .fixedSize()
        }
        //.defaultSize(CGSize(width: 600, height: 400))
        //.defaultPosition(.center)
        .windowResizability(.contentSize)
    }
}
