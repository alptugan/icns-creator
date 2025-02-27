//
//  ContentView.swift
//  icns creator
//
//  Created by alp tugan on 10.08.2023.
//
//  Update: v2.2 on 07.09.2024
//  Update: v3.4 on 09.09.2024 -scaleFactor warnings cleared, Thread optimization (waiting)
//  Update: v3.5 on 14.09.2024 -ask for destination path: destinationPath,selectedImageName

import SwiftUI
import Foundation
import Cocoa
import Combine


extension NSOpenPanel {
    static func openImage(completetion: @escaping (_ result: Result<NSImage, Error>, _ url: URL?) -> ()) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [.image]
        }else{
            panel.allowedFileTypes = ["jpg", "jpeg", "png", "gif"]
        }
        panel.begin { result in
            if result == .OK, let url = panel.urls.first, let image = NSImage(contentsOf: url) {
                completetion(.success(image), url)
                //self.imagepa
            }else{
                completetion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])), nil)
            }
        }
    }
}

func selectFileFromSystem(g: GlobalVariables) {
    let openPanel = NSOpenPanel()
    if #available(macOS 12.0, *) {
        openPanel.allowedContentTypes = [.image]
    }else{
        openPanel.allowedFileTypes = ["jpg", "jpeg", "png", "gif"]
    }
    openPanel.canChooseFiles = true
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false

    openPanel.begin { result in
        if result == .OK, let url = openPanel.url {
            if let image = NSImage(contentsOf: url) { // Load the image properly
                g.selectedImage = image
                g.imagePath = url.path
                g.selectedImageName = url.deletingPathExtension().lastPathComponent
            } else {
                print("Failed to load image.")
            }
        }
    }
}

//-------------------------------------------------------------------------------------------------
// PART 1: GENERATE ICNS
//-------------------------------------------------------------------------------------------------
func runShellCommand(g: GlobalVariables) {
    guard let imagePath = g.imagePath else {
        print("imagePath is nil.")
        return
    }
    
    let escapedImagePath = imagePath.replacingOccurrences(of: " ", with: "\\ ")
    

    //let escapedIconPath = "\(escapedImageName).iconset"
    let escapedIconPath = g.destinationPath + "/" + g.selectedImageName + ".iconset"
    let fileManager = FileManager.default
    


    // Check and create directory
    var isDirectory: ObjCBool = false
    if !fileManager.fileExists(atPath: escapedIconPath, isDirectory: &isDirectory) {
        print("The directory does not exist. Creating...")
        try? fileManager.createDirectory(atPath: escapedIconPath, withIntermediateDirectories: true, attributes: nil)
    } else if !isDirectory.boolValue {
        print("A file exists at the specified path, not a directory.")
        return
    }
    
    let sizes: [Int] = [16, 32, 128, 256, 512]

    for size in sizes {
        processImage(size: size, scale: 1, escapedImagePath: escapedImagePath, escapedIconPath: escapedIconPath, g: g)
        processImage(size: size * 2, scale: 2, escapedImagePath: escapedImagePath, escapedIconPath: escapedIconPath, g: g)
    }
}

func processImage(size: Int, scale: Int, escapedImagePath: String, escapedIconPath: String, g: GlobalVariables) {
    
    guard let roundedImage = createRoundedImage(from: escapedImagePath, size: size, _isRoundCornersEnabled: g.enableRoundedCorners, _enableShadow: g.enableIconShadow, _enablePadding: g.enablePadding) else { return }

    guard let tiffData = roundedImage.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return }
    
    let outputPath = "\(escapedIconPath)/icon_\(size / scale)x\(size / scale)\(scale > 1 ? "@2x" : "").png"
    
    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        try runSipsCommand(size: size, outputPath: outputPath, g: g)

    } catch {
        print("Error processing size \(size): \(error)")
    }
}

//-------------------------------------------------------------------------------------------------
// RUN SIPS COMMAND
//-------------------------------------------------------------------------------------------------
func runSipsCommand(size: Int, outputPath: String, g: GlobalVariables) throws {
    let command = "sips -s format png -z \(size) \(size) \(outputPath) --out \(outputPath)"
    let process = Process()
    
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", command]
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    
    process.launch()
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: outputData, encoding: .utf8) {
        g.outputText = output
    }
    
}

//-------------------------------------------------------------------------------------------------
// CREATE ROUNDED CORNERS
//-------------------------------------------------------------------------------------------------
func createRoundedImage(from path: String, size: Int, _isRoundCornersEnabled: Bool, _enableShadow: Bool, _enablePadding: Bool) -> NSImage? {
    guard let image = NSImage(contentsOfFile: path) else { return nil }
   // let image = loadImage(named: path)

    // Ensure size is valid
    guard size > 0 else {
        print("Invalid size: \(size). Returning nil.")
        return nil
    }
    
    // Scale down sizes according to the specified rules
    var scaledSize: Int
    if (_enablePadding) {
        switch size {
        case 1024: scaledSize = 824
        case 512:  scaledSize = 412
        case 256:  scaledSize = 206
        case 128:  scaledSize = 103
        case 64:   scaledSize = 52
        case 32:   scaledSize = 28
        case 16:   scaledSize = 14
        default:   scaledSize = size // Fallback to original size if not specified
        }
    }else{
        scaledSize = size
    }
    
    // Create a new NSImage with the original size
    let finalImage = NSImage(size: NSSize(width: size, height: size))

    // Calculate radius for rounded corners
    
    // Calculate radius for rounded corners
    var radiusVal:Double = 0
    if (_isRoundCornersEnabled) {
        radiusVal = 0.225 * Double(scaledSize)
    }
    let bezierPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size), xRadius: radiusVal, yRadius: radiusVal)

    finalImage.lockFocus()
    
    // Clip to the larger rounded rectangle
    bezierPath.addClip()

    // Calculate the origin to center the scaled-down image
    let xOffset = (size - scaledSize) / 2
    let yOffset = (size - scaledSize) / 2

    // Create a new NSImage for the scaled image
    let scaledImage = NSImage(size: NSSize(width: scaledSize, height: scaledSize))
    scaledImage.lockFocus()

    // Create a path for the scaled image with rounded corners
    let scaledBezierPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: scaledSize, height: scaledSize), xRadius: radiusVal, yRadius: radiusVal)
    
    // Clip to the rounded rectangle for the scaled image
    scaledBezierPath.addClip()

    // Draw the scaled image centered
    image.draw(in: NSRect(x: 0, y: 0, width: scaledSize, height: scaledSize), from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

    // Unlock the scaled image focus
    scaledImage.unlockFocus()

    // Prepare to draw the shadow for the scaled image
    if(_enableShadow) {
        let shadow = NSShadow()
        let shadowRadius = floor(Double(scaledSize) * 0.034)
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.shadowBlurRadius = CGFloat(shadowRadius)  // Set shadow blur radius
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)  // Set shadow color
        
        // Draw the shadow and the scaled image
        finalImage.lockFocus()
        shadow.set()
    }
    // Draw the scaled image in the final image
    scaledImage.draw(in: NSRect(x: xOffset, y: yOffset, width: scaledSize, height: scaledSize), from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

    finalImage.unlockFocus()

    return finalImage
}

func loadImage(named imageName: String) -> NSImage? {
    // Attempt to load the image from the app bundle
    if let image = NSImage(named: imageName) {
        return image
    }
    
    // Optionally, you can try loading from a specific path
    if let path = Bundle.main.path(forResource: imageName, ofType: "png") {
        guard let image = NSImage(contentsOfFile: path) else { return nil }
        return image
    }
    
    return nil // Return nil if the image could not be loaded
}

extension NSBitmapImageRep {
    func pngRepresentation() -> Data? {
        return self.representation(using: .png, properties: [:])
    }
}

//-------------------------------------------------------------------------------------------------
// PART 2: RUN FOR SEPERATE .icns files
//-------------------------------------------------------------------------------------------------
func runShellCommand2(res: Int, g: GlobalVariables) {

    let process = Process()
    // file path with extension
    var escapedImagePath = g.imagePath!.replacingOccurrences(of: " ", with: "\\ ")
    
    // file path without extension
    //var escapedImagePath2 = g.imagePath!.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
    
    var escapedImagePath2 = g.destinationPath + "/" + g.selectedImageName + ".iconset"

    
    guard let roundedImage = createRoundedImage(from: escapedImagePath, size: res, _isRoundCornersEnabled: g.enableRoundedCorners, _enableShadow: g.enableIconShadow, _enablePadding: g.enablePadding) else { return }

    guard let tiffData = roundedImage.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return }
    
    
    let outputPath = "\(String(describing:escapedImagePath2 ))_\(String(res))x\(String(res)).png"
    
    escapedImagePath = outputPath.replacingOccurrences(of: " ", with: "\\ ")
    escapedImagePath2 = outputPath.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
    
    
    
    
    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))

    } catch {
        print("Error processing size \(res): \(error)")
    }
    
    
    var command = ""
    
    if res == 32 || res == 64 || res == 256 || res == 512 || res == 1024 {
        command = "sips --setProperty dpiWidth 144 --setProperty dpiHeight 144 -s format icns -z \(Int(res)) \(Int(res)) \(String(describing:escapedImagePath )) --out \(escapedImagePath2)_\(String(res))x\(String(res)).icns"
    } else {
        command = "sips --setProperty dpiWidth 72 --setProperty dpiHeight 72 -s format icns -z \(Int(res)) \(Int(res)) \(String(describing:escapedImagePath )) --out \(escapedImagePath2)_\(String(res))x\(String(res)).icns"
    }
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", command]
    
    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    
    process.launch()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: outputData, encoding: .utf8) {
        g.outputText = output
    }
    
    process.waitUntilExit()
    
    // Second pass for setting preview image
    let command2 = "sips -i \(String(describing:escapedImagePath2 ))_\(String(res))x\(String(res)).icns \(String(describing:escapedImagePath2 ))_\(String(res))x\(String(res)).icns"
    
    let process2 = Process()
    process2.launchPath = "/bin/zsh"
    process2.arguments = ["-c", command2]
    
    let outputPipe2 = Pipe()
    process2.standardOutput = outputPipe2
    
    process2.launch()
    
    let outputData2 = outputPipe2.fileHandleForReading.readDataToEndOfFile()
    if let output2 = String(data: outputData2, encoding: .utf8) {
        g.outputText2 = output2
    }
    
    process2.waitUntilExit()
    
    // Delete the generated PNG file
    let fileManager = FileManager.default
    do {
        try fileManager.removeItem(atPath: outputPath)
        print("Successfully deleted PNG file at path: \(outputPath)")
    } catch {
        print("Error deleting PNG file: \(error)")
    }
}

// GENERATE .ICONSET File
func generateCombinedIcns(g: GlobalVariables) {
    let process = Process()
    
    //let escapedImageName = g.imagePath!.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
    
    //let escapedIconPath = escapedImageName + ".iconset"
    let escapedIconPath = g.destinationPath + "/" + g.selectedImageName + ".iconset"
    
   /* let fileManager = FileManager.default
    if fileManager.fileExists(atPath: escapedIconPath) {
        print("File exists iconset")
    } else {
        print("File does not exist iconset")
        let mkdirProcess = Process()
        mkdirProcess.launchPath = "/bin/bash"
        mkdirProcess.arguments = ["-c", "mkdir " + escapedIconPath]
        mkdirProcess.launch()
    }*/
    let mkdirProcess = Process()
    mkdirProcess.launchPath = "/bin/bash"
    mkdirProcess.arguments = ["-c", "mkdir " + escapedIconPath]
    mkdirProcess.launch()
    
    let command = "iconutil -c icns \(escapedIconPath)"
    
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", command]
    
    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    
    process.launch()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: outputData, encoding: .utf8) {
        g.outputText = output
    }
    
    process.waitUntilExit()
}

// MAIN CONTENT VIEW TABS
struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var g: GlobalVariables // Access the global variables
    
    
    var body: some View {
        
        // NAVIGATION MENU
        // If image is selected then show the tabs
        if g.selectedImage != nil {
            if #available(macOS 14.0, *) {
                VStack() {
                    Picker("", selection: $selectedTab) {
                        Text(".iconset").tag(0)
                        Text(".icns").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(height: 10)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .accentColor(.blue)
                    .onChange(of: selectedTab) { oldValue, newValue in
                        // window size
                        let newHeight: CGFloat = newValue == 0 ? 520 : 570
                        resizeWindow(g: g, to: CGSize(width: g.win.size.width, height: newHeight))
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                    }
                    .onAppear {
                        resizeWindow(g: g, to: CGSize(width: g.win.size.width, height: 520))
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                    }
                }
            }else{
                VStack() {
                    Picker("", selection: $selectedTab) {
                        Text(".iconset").tag(0)
                        Text(".icns").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(height: 10)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .accentColor(.blue)
                    .onChange(of: selectedTab) { newValue in
                        // window size
                        let newHeight: CGFloat = newValue == 0 ? 520 : 570
                        resizeWindow(g: g, to: CGSize(width: g.win.size.width, height: newHeight))
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                    }
                    .onAppear {
                        resizeWindow(g: g, to: CGSize(width: g.win.size.width, height: 520))
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        
                    }
                }
            }
        }
        
        // Contents
        ZStack {
            CommonView()
                .onAppear{
                    g.win.size.width = 350
                    g.win.size.height = 250
                    g.dragAreaPos.x = 210
                    g.dragAreaPos.y = -250
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
        
        // Generate  Buttons
        VStack() {
            switch selectedTab {
            case 0:
                GenerateView_ICONSET()
            case 1:
                GenerateView_ICNS()
            default:
                EmptyView()
            }
        }
    }
}


// COMMON ELEMENTS
struct CommonView: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables
    @State private var showScrollBars: String = "When scrolling"
       @State private var clickAction: String = "Jump to the next page"
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .frame(width:280,height: 250) // The size of drop image area
                    .overlay(
                        Group {
                            GeometryReader { geometry in
                                // dash line around the drop location
                                RoundedRectangle(cornerRadius: 27.1)
                                    .stroke(g.dragOver ? Color.blue : Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 3, dash:[4]))
                                    .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.85)
                                    .background(g.dragOver ? Color.blue.opacity(0.1) : Color.white) // If nothing dragged onto section
                                    .cornerRadius(27.1)
                                    .position(x: geometry.frame(in: .local).midX, y:geometry.frame(in: .local).midY)
                                
                                VStack {
                                    //Spacer()
                                    // If the image is selected - Preview of the image
                                    if g.selectedImage != nil {
                                        GeometryReader { geo in
                                            let localFrame = geo.frame(in: .local)
                                            let ww = g.enablePadding ? g.imgW - 20 : g.imgW
                                            let hh = g.enablePadding ? g.imgH - 20 : g.imgH
                                            VStack {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 27.1)
                                                        .frame(width: ww , height: hh)
                                                        .shadow(radius: g.enableIconShadow ? 10 : 0)
                                                    
                                                    Image(nsImage: g.selectedImage!)
                                                        .resizable()
                                                        .frame(width: ww , height: hh)
                                                        .cornerRadius(g.enableRoundedCorners ? 27.1 : 0)
                                                }.position(x:localFrame.midX, y: localFrame.maxY)
                                                
                                            }
                                        }
                                    }
                                    
                                    // If no image is selected
                                    if g.selectedImage == nil {
                                        ZStack {
                                            GeometryReader { geo in
                                                let localFrame = geo.frame(in: .local)
                                                Image("imgcolor")
                                                    .resizable()
                                                    .scaleEffect(g.dragOver ? 1.0 : 0.1)
                                                    .position(x:g.dragOver ? localFrame.midX : localFrame.midX, y: localFrame.maxY - 20)
                                                
                                                Image("drag")
                                                    .resizable()
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .position(x: localFrame.midX + 10, y: g.dragOver ? localFrame.maxY  : localFrame.maxY - 15)
                                                    .opacity(g.dragOver ? 0 : 1)
                                            }
                                        }.frame(width: g.imgW, height: g.imgH)
                                    }
                                    
                                    // Display the text always
                                    GeometryReader { geo in
                                        let localFrame = geo.frame(in: .local)
                                        VStack {
                                            
                                            HStack {
                                                Text("Drag your image here or ")
                                                    .foregroundColor(.gray)
                                                    .font(.subheadline)
                                                
                                                Text("Browse")
                                                    .foregroundColor(.blue)
                                                    .font(.headline).bold()
                                                    .padding(-6)
                                                    .onHover { isHover in
                                                        if isHover {
                                                            NSCursor.pointingHand.set()
                                                        }else{
                                                            NSCursor.arrow.set()
                                                        }
                                                    }
                                            }
                                        }.position(x:localFrame.midX, y: localFrame.maxY + 20)
                                        
                                        //-------------------------------------------------------------------------------------
                                        // ICON OPTIONS
                                        //-------------------------------------------------------------------------------------
                                        
                                        if g.selectedImage != nil {
                                            // Toggle for enabling ROUNDED corners
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text("Options")
                                                    .font(.callout)
                                                
                                                HStack {
                                                    Text("Enable Rounded Corners")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                    
                                                    Toggle(isOn: $g.enableRoundedCorners) {
                                                        //Label("Flag", systemImage: "flag.fill")
                                                    }
                                                    .toggleStyle(SwitchToggleStyle())
                                                    .labelsHidden()
                                                    .scaleEffect(0.7)
                                                    .offset(x:5)
                                                }
                                                
                                                //.position(x: localFrame.midX, y: 0) // Position the toggle
                                                
                                                HStack {
                                                    Text("Enable Subtle Shadow")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                    
                                                    Toggle(isOn: $g.enableIconShadow) {
                                                    }
                                                    .toggleStyle(SwitchToggleStyle())
                                                    .labelsHidden()
                                                    .fixedSize()
                                                    .scaleEffect(0.7)
                                                    .offset(x:5)
                                                }
                                                
                                                HStack {
                                                    Text("Enable Original Padding")
                                                        .font(.footnote)
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                    
                                                    Toggle(isOn: $g.enablePadding) {
                                                    }
                                                    .toggleStyle(SwitchToggleStyle())
                                                    .labelsHidden()
                                                    .fixedSize()
                                                    .scaleEffect(0.7)
                                                    .offset(x:5)
                                                }
                                            }
                                            .padding(.all, 12)
                                            //.frame(width: g.win.size.width - 70, height: 300)
                                            .background(Color.gray.opacity(0.05))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(Color.secondary.opacity(0.4), antialiased: false)
                                                //.stroke(Color.secondary.opacity(0.5), lineWidth: 1) // Stroke color and width
                                                    
                                            )
                                            .position(x: localFrame.midX, y: localFrame.maxY + 95) // Position the toggle
                                        }
                                    }

                                }
                            }
                        }
                    ) // Inside The content
                    .onDrop(of: ["public.file-url"], isTargeted: Binding<Bool>(get: { g.dragOver }, set: { g.dragOver = $0 }).animation()) { providers in

                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, error in

                            if let imageData = data, let path = NSString(data: imageData, encoding: String.Encoding.utf8.rawValue), // Use UTF-8 encoding
                               let url = URL(string: path as String) {

                                // Ensure updates to the model happen on the main thread
                                DispatchQueue.main.async {
                                    g.imagePath = url.path
                                    g.selectedImageName = url.deletingPathExtension().lastPathComponent
                                    if let image = NSImage(contentsOf: url) {
                                        g.selectedImage = image
                                    }
                                }
                            }
                        })
                        return true
                    } // Show dropped image
                    .onTapGesture {
                        selectFileFromSystem(g:g)
                    } // Show Browse window
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.top, g.selectedImage == nil ? 20 : 0)
        }.environmentObject(g.win)
    }
}


// ONLY CREATE ICONSET FOLDER
struct GenerateView_ICONSET: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables

    var body: some View {
        // After the image is displayed in the container, show the Convert <Button>
        if g.selectedImage != nil {
            VStack {
                Spacer(minLength: 185)
                HStack {
                    Button("Generate .iconset") {
                        let openPanel = createOpenPanel(defaultDirectory: URL(fileURLWithPath: NSHomeDirectory()))

                        // Show the panel and handle the user's selection
                        openPanel.begin { response in
                            if response == .OK, let selectedDirectory = openPanel.url {
                                g.destinationPath = selectedDirectory.path
                                
                                // Generate images
                                runShellCommand(g: g)
                                generateCombinedIcns(g: g)
                            }
                        }
                    }
                }
                Spacer() // Optional: Space below the button
            }
            .frame(maxHeight: .infinity) // Ensure VStack takes full height
        }
    }
}


struct GenerateView_ICNS: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables

    var allTogglesOff: Bool {
        return !g.isToggled_All && !g.isToggled_16 && !g.isToggled_32 && !g.isToggled_64 && !g.isToggled_128 && !g.isToggled_256 && !g.isToggled_512 && !g.isToggled_1024
    }
    var body: some View {
        VStack {
            Spacer(minLength: 150)
            if g.selectedImage != nil {
                Spacer()
                HStack {
                    if #available(macOS 14.0, *) {
                        Toggle("All", isOn: $g.isToggled_All)
                            .onChange(of: g.isToggled_All) {
                                oldvalue, newValue in
                                //if newValue {
                                g.isToggled_16 = newValue
                                g.isToggled_32 = newValue
                                g.isToggled_64 = newValue
                                g.isToggled_128 = newValue
                                g.isToggled_256 = newValue
                                g.isToggled_512 = newValue
                                g.isToggled_1024 = newValue
                                //}
                            }
                    }else{
                        Toggle("All", isOn: $g.isToggled_All)
                            .onChange(of: g.isToggled_All) {
                                newValue in
                                //if newValue {
                                g.isToggled_16 = newValue
                                g.isToggled_32 = newValue
                                g.isToggled_64 = newValue
                                g.isToggled_128 = newValue
                                g.isToggled_256 = newValue
                                g.isToggled_512 = newValue
                                g.isToggled_1024 = newValue
                                //}
                            }
                    }
                    Toggle("16x16", isOn: $g.isToggled_16)
                    Toggle("32x32", isOn: $g.isToggled_32)
                    Toggle("64x64", isOn: $g.isToggled_64)
                } // Toggle buttons first row
                HStack {
                    Toggle("128x128", isOn: $g.isToggled_128)
                    Toggle("256x256", isOn: $g.isToggled_256)
                    Toggle("512x512", isOn: $g.isToggled_512)
                    Toggle("1024x1024", isOn: $g.isToggled_1024)
                } // Toggle buttons second row
                Spacer(minLength: 5)

                HStack {
                    Button("Generate .icns") {
                        let openPanel = createOpenPanel(defaultDirectory: URL(fileURLWithPath: NSHomeDirectory()))
                        
                        // Show the panel and handle the user's selection
                        openPanel.begin { response in
                            if response == .OK, let selectedDirectory = openPanel.url {
                                g.destinationPath = selectedDirectory.path
                                
                                if(g.isToggled_16 == true) {
                                    runShellCommand2(res:16,g:g)
                                }
                                
                                if(g.isToggled_32 == true) {
                                    runShellCommand2(res:32, g:g)
                                }
                                
                                if(g.isToggled_64 == true) {
                                    runShellCommand2(res:64, g:g)
                                }
                                
                                if(g.isToggled_128 == true) {
                                    runShellCommand2(res:128, g:g)
                                }
                                
                                if(g.isToggled_256 == true) {
                                    runShellCommand2(res:256, g:g)
                                }
                                
                                if(g.isToggled_512 == true) {
                                    runShellCommand2(res:512, g:g)
                                }
                                
                                if(g.isToggled_1024 == true) {
                                    runShellCommand2(res:1024, g:g)
                                }
                            }
                        }
                        
                        
                    }
                    .disabled(allTogglesOff)
                } // Button
                Spacer() // Optional: Space below the button
            }
        }
        .frame(maxHeight: .infinity) // Ensure VStack takes full height

    }
}

// File location choose dialog
func createOpenPanel(defaultDirectory: URL? = nil) -> NSOpenPanel {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.title = "Choose Destination" // Title of the dialog
    openPanel.message = "Select a folder to save the .iconset" // Message displayed in the dialog
    openPanel.prompt = "Choose" // Label for the confirmation button
    
    if let defaultDirectory = defaultDirectory {
        openPanel.directoryURL = defaultDirectory // Set default directory
    }
    
    return openPanel
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Global function to resize the window
func resizeWindow(g: GlobalVariables, to size: CGSize) {
    // Print the size for debugging
    //print("Resizing window to \(size)")
    
    if let window = NSApplication.shared.windows.first {
        window.setContentSize(size)
        // Optionally, you can also center the window
        //window.center()
        
        window.disableCursorRects()
        window.styleMask.remove(.resizable)
        
    }
}
