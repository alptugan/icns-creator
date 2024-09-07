//
//  ContentView.swift
//  icns creator
//
//  Created by alp tugan on 10.08.2023.
//

import SwiftUI
import Foundation
import Cocoa


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
    NSOpenPanel.openImage { result, url in
        if case let .success(image) = result {
            g.selectedImage = image
            g.imagePath = url?.path
        }
    }
}

// RUN FOR SINGLE ICONSET
/*func runShellCommand(g: GlobalVariables) {
    guard let imagePath = g.imagePath else {
        print("imagePath is nil.")
        return
    }
    
    let escapedImagePath = imagePath.replacingOccurrences(of: " ", with: "\\ ")
    let escapedImageName = imagePath.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
    
    // Create ".iconset" file
    let escapedIconPath = escapedImageName + ".iconset"
    let fileManager = FileManager.default
    let directoryPath = escapedIconPath
    var isDirectory: ObjCBool = false
    
    if fileManager.fileExists(atPath: directoryPath, isDirectory: &isDirectory) {
        if isDirectory.boolValue {
            print("The directory exists.")
        } else {
            print("A file exists at the specified path, not a directory.")
        }
    } else {
        print("The directory does not exist.")
        let mkdirProcess = Process()
        mkdirProcess.launchPath = "/bin/bash"
        mkdirProcess.arguments = ["-c", "mkdir " + escapedIconPath]
        mkdirProcess.launch()
    }
    
    let sizes: [Int] = [16, 32, 128, 256, 512]
    
    for size in sizes {
        let process = Process()
        process.launchPath = "/bin/bash"
        
        let command = "sips -s format png -z \(size) \(size) \(String(describing:escapedImagePath)) --out \(escapedIconPath)/icon_\(size)x\(size).png"
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
    
    // @2x files
    let sizes2: [Int] = [16, 32, 128, 256, 512]
    for size in sizes2 {
        let process = Process()
        process.launchPath = "/bin/bash"
        
        let nSz = size * 2
        
        let command = "sips -s format png -z \(nSz) \(nSz) \(String(describing:escapedImagePath)) --out \(escapedIconPath)/icon_\(size)x\(size)@2x.png"
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
    
}
*/

/*
func runShellCommand(g: GlobalVariables) {
    guard let imagePath = g.imagePath else {
        print("imagePath is nil.")
        return
    }
    
    let escapedImagePath = imagePath.replacingOccurrences(of: " ", with: "\\ ")
    let escapedImageName = imagePath.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
    
    // Create ".iconset" file
    let escapedIconPath = escapedImageName + ".iconset"
    let fileManager = FileManager.default
    let directoryPath = escapedIconPath
    var isDirectory: ObjCBool = false
    
    
    
    if !fileManager.fileExists(atPath: directoryPath, isDirectory: &isDirectory) {
        print("The directory does not exist. Creating...")
        try? fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    } else if !isDirectory.boolValue {
        print("A file exists at the specified path, not a directory.")
        return
    }
    

    let sizes: [Int] = [16, 32, 128, 256, 512]
    

    for size in sizes {
        if let roundedImage = createRoundedImage(from: escapedImagePath, size: size) {
            if let tiffData = roundedImage.tiffRepresentation,
               let bitmapRep = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                let outputPath = "\(escapedIconPath)/icon_\(size)x\(size).png"
                try? pngData.write(to: URL(fileURLWithPath: outputPath))
                let process = Process()
                process.launchPath = "/bin/bash"
                
                let command = "sips -s format png -z \(size) \(size) \(String(describing:outputPath)) --out \(escapedIconPath)/icon_\(size)x\(size).png"
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
        }
    }
    
    // @2x files
    for size in sizes {
        let nSz = size * 2
        
        if let roundedImage = createRoundedImage(from: escapedImagePath, size: nSz) {
            if let tiffData = roundedImage.tiffRepresentation,
               let bitmapRep = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                let outputPath = "\(escapedIconPath)/icon_\(size)x\(size)@2x.png"
                try? pngData.write(to: URL(fileURLWithPath: outputPath))
                let process = Process()
                process.launchPath = "/bin/bash"
                                
                let command = "sips -s format png -z \(nSz) \(nSz) \(String(describing:outputPath)) --out \(escapedIconPath)/icon_\(size)x\(size)@2x.png"
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
        }
    }
}
 */

//-------------------------------------------------------------------------------------------------
// PART 1: GENERATE ICNS
//-------------------------------------------------------------------------------------------------
func runShellCommand(g: GlobalVariables) {
    guard let imagePath = g.imagePath else {
        print("imagePath is nil.")
        return
    }
    
    let escapedImagePath = imagePath.replacingOccurrences(of: " ", with: "\\ ")
    let escapedImageName = imagePath.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
    
    let escapedIconPath = "\(escapedImageName).iconset"
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
    guard let roundedImage = createRoundedImage(from: escapedImagePath, size: size) else { return }
    
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
func createRoundedImage(from path: String, size: Int) -> NSImage? {
    guard let image = NSImage(contentsOfFile: path) else { return nil }

    // Ensure newSize is valid
    guard size > 0 else {
        print("Invalid newSize: \(size). Returning nil.")
        return nil
    }

    
    let roundedRect = NSRect(x: 0, y: 0, width: size, height: size)
    // Calculate radius
    let radiusVal = 0.225 * Double(size)
    
    let bezierPath = NSBezierPath(roundedRect: roundedRect, xRadius: radiusVal, yRadius: radiusVal)

    let imageSize = NSSize(width: size, height: size)
    let roundedImage = NSImage(size: imageSize)

    roundedImage.lockFocus()
    bezierPath.addClip()
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size)) // Use newSize here
    roundedImage.unlockFocus()

    return roundedImage
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
    let escapedImagePath = g.imagePath!.replacingOccurrences(of: " ", with: "\\ ")
    //let escapedImagePath = imagePath?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    
    //let idd = escapedImagePath?.lastIndex(of: ".")
    //let fname = escapedImagePath.
    //let subi = escapedImagePath?[&idd...]
    
    let escapedImagePath2 = g.imagePath!.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
    
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
}

// GENERATE .ICONSET File
func generateCombinedIcns(g: GlobalVariables) {
    let process = Process()
    
    let escapedImageName = g.imagePath!.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
    
    let escapedIconPath = escapedImageName + ".iconset"
    
    
    
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: escapedIconPath) {
        print("File exists iconset")
    } else {
        print("File does not exist iconset")
        let mkdirProcess = Process()
        mkdirProcess.launchPath = "/bin/bash"
        mkdirProcess.arguments = ["-c", "mkdir " + escapedIconPath]
        mkdirProcess.launch()
    }
    
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
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text(".iconset").tag(0)
                    Text(".icns").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(height: 10)
                .padding()
                .frame(maxWidth: .infinity)
                .accentColor(.blue)
                //.background(Color.gray.opacity(0.15)) // Set background color
                
                
                switch selectedTab {
                case 0:
                    GenerateView_ICONSET()
                case 1:
                    GenerateView_ICNS()
                default:
                    EmptyView()
                }
                Spacer()
                
                
                //   CommonView()
            }
        }
        //.overlay(
            // Some problematic positioning issue
            // If some one can fix it, would be great!!!!
        ZStack {
            CommonView()
                .onAppear{
                    g.win.size.width = 350
                    g.win.size.height = 450
                    g.dragAreaPos.x = 210
                    g.dragAreaPos.y = -50
                }
                .position(x: g.dragAreaPos.x, y: g.selectedImage != nil ? -50 : g.win.size.height * 0.65)
            //)
        }
    }
}

// COMMON ELEMENTS
struct CommonView: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables
    
    var body: some View {
        GeometryReader { geo in
            ZStack (alignment: .center){
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .frame(width:280,height: 250,alignment: Alignment.top) // the wxh of the drop area
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
                                    // If the image is selected
                                    if g.selectedImage != nil {
                                        GeometryReader { geo in
                                            let localFrame = geo.frame(in: .local)
                                            VStack {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 27.1)
                                                    //.stroke(Color.blue, style: StrokeStyle(lineWidth: 4))
                                                        .frame(width: g.imgW , height: g.imgH)
                                                        .shadow(radius: 10)
                                                    
                                                    Image(nsImage: g.selectedImage!)
                                                        .resizable()
                                                        //.scaledToFit()
                                                        .frame(width: g.imgW, height: g.imgH)
                                                        .cornerRadius(27.1)
                                                }.position(x:localFrame.midX, y: localFrame.maxY).onAppear{
                                                    // Print the value of g.imgW to the console
                                                    // print("g.imgW: \(g.imgW)") 150 px
                                                }
                                                
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
                                                    .scaleEffect(g.dragOver ? 1 : 0)
                                                    .position(x:g.dragOver ? localFrame.midX : localFrame.midX, y: localFrame.maxY - 20)
                                                
                                                Image("drag")
                                                    .resizable()
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .position(x: localFrame.midX + 10, y: g.dragOver ? localFrame.maxY  : localFrame.maxY - 15)
                                                    .opacity(g.dragOver ? 0 : 1)
                                            }
                                        }.frame(width: g.imgW, height: g.imgH)
                                        
                                        //Text("No image selected")
                                        //showBrowseButton()
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
                                    }
                                    
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Image drawing on canvas
                            }
                        }
                    ) // Inside The content
                    .onDrop(of: ["public.file-url"], isTargeted: Binding<Bool>(get: { g.dragOver }, set: { g.dragOver = $0 }).animation()) { providers in
                        
                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, error in
                            
                            if let imageData = data, let path = NSString(data: imageData, encoding: 4),
                               let url = URL(string: path as String) {
                                
                                g.imagePath = url.path
                                
                                let image = NSImage(contentsOf: url)
                                DispatchQueue.main.async {
                                    g.selectedImage = image
                                }
                            }
                            
                        })
                        return true
                    } // Show dropped image
                    .onTapGesture {
                        selectFileFromSystem(g:g)
                    } // Show Browse window
            }
            .onAppear {
                g.win.size = geo.size
            }
        }.environmentObject(g.win)
        
    }
}


// ONLY CREATE ICONSET FOLDER
struct GenerateView_ICONSET: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables
    
    var body: some View {
        
        
        // After the image is display in the container show Convert <Button>
        if g.selectedImage != nil {
            VStack {
                HStack {
                    Button("Generate .iconset") {
                        runShellCommand(g:g)
                        generateCombinedIcns(g:g)
                    }
                }
            }.position(x: g.dragAreaPos.x * 0.85, y: 350)
        }
    }
}



struct GenerateView_ICNS: View {
    @EnvironmentObject var g: GlobalVariables // Access the global variables

    var allTogglesOff: Bool {
        return !g.isToggled_All && !g.isToggled_16 && !g.isToggled_32 && !g.isToggled_64 && !g.isToggled_128 && !g.isToggled_256 && !g.isToggled_512 && !g.isToggled_1024
    }
    var body: some View {
        /*Text("Swap Content")
            .font(.largeTitle)
            .padding()*/
        
        VStack (alignment: .center) {
            if g.selectedImage != nil {
                HStack {
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
                HStack {
                    Button("Generate .icns") {
                        //resizeAndSaveImage(imagePath: imagePath, width: imgW, height: imgW)
                        //print("Toggle 1 value: \(isToggled_16)")
                        if(g.isToggled_16 == true) {
                            //resizeAndSaveImage(imagePath: imagePath, width: 16, height: 16)
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
                    .disabled(allTogglesOff)
                } // Button
            }
        }.position(x: g.dragAreaPos.x * 0.85, y: 350)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
