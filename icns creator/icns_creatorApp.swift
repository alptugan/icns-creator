//
//  icns_creatorApp.swift
//  icns creator
//
//  Created by alp tugan on 10.08.2023.
//

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
    
    var winWidth: CGFloat {
        return winSize.width - winSize.width * 0.85
    }
}


@main
struct icns_creatorApp: App {
    @StateObject private var globalVariables = GlobalVariables() // Instantiate the GlobalVariables object as a state object

    var body: some Scene {
        
        WindowGroup {
            let w:CGFloat = 350
            let h:CGFloat = 450
            
            ContentView()
                .frame(minWidth: w,maxWidth: w,minHeight: h,maxHeight: h)
                .fixedSize(horizontal: false, vertical: true)
                .environmentObject(globalVariables)
                 
        }
        //.defaultSize(CGSize(width: 600, height: 400))
        //.defaultPosition(.center)
        .windowResizabilityContentSize()
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
