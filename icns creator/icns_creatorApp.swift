//
//  icns_creatorApp.swift
//  icns creator
//
//  Created by alp tugan on 10.08.2023.
//  Update: v2.2 on 04.09.2024
//  Update: v2.4 on 08.09.2024
//  Update: v3.4 on 09.09.2024

import SwiftUI


class WindowSize: ObservableObject {
    @Published var size: CGSize = .zero
}

class GlobalVariables: ObservableObject {
    @Published var winSize: CGSize = .zero
    
    @Published var dragAreaPos : CGPoint = .zero
    @Published var isToggled_All = true
    @Published var isToggled_16 = true
    @Published var isToggled_32 = true
    @Published var isToggled_64 = true
    @Published var isToggled_128 = true
    @Published var isToggled_256 = true
    @Published var isToggled_512 = true
    @Published var isToggled_1024 = true
    @Published var imagePath: String?
    @Published var imgW: CGFloat = 150
    @Published var imgH: CGFloat = 150
    @Published var urlg:URL?
    
    @Published var outputText = ""
    @Published var outputText2 = ""
    
    @Published var dragOver : Bool = false
    @Published var selectedImage = NSImage(named: "image")
    @Published var win = WindowSize()
    
    @Published var enableRoundedCorners: Bool = true // Toggle state
    @Published var enableIconShadow: Bool = true // Toggle state
    @Published var enablePadding: Bool = true // Toggle state
}


@main
struct icns_creatorApp: App {
    @StateObject private var globalVariables = GlobalVariables() // Instantiate the GlobalVariables object as a state object

    var body: some Scene {
        let w:CGFloat = 350
        let h:CGFloat = 320
        
        WindowGroup {
            
            
            ContentView()
                .frame(minWidth: w,maxWidth: w,minHeight: h)
                .environmentObject(globalVariables)
                .onAppear {

                    DispatchQueue.main.async {
                        resizeWindow(g:globalVariables,to: CGSize(width: w, height: h))
                        
                    }
                }
                 
        }
        //.defaultSize(CGSize(width: w, height: h))
        //.defaultPosition(.center)
        //.windowResizabilityContentSize()
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
