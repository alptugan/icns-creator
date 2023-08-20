//
//  ContentView.swift
//  icns creator
//
//  Created by alp tugan on 10.08.2023.
//

import SwiftUI

@available(macOS 11.0, *)
struct ContentView: View {
    @State private var isToggled_All = true
    @State private var isToggled_16 = true
    @State private var isToggled_32 = true
    @State private var isToggled_128 = true
    @State private var isToggled_256 = true
    @State private var isToggled_512 = true
    @State private var imagePath: String?
    @State private var imgW: CGFloat = 200
    @State private var imgH: CGFloat = 200
    @State private var urlg:URL?
    
    @State private var outputText = ""
    @State private var outputText2 = ""

    var allTogglesOff: Bool {
          return !isToggled_All && !isToggled_16 && !isToggled_32 && !isToggled_128 && !isToggled_256 && !isToggled_512
    }
    
    var body: some View {
        
        VStack {
            
            if let imagePath = imagePath, let image = NSImage(contentsOfFile: imagePath) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imgW, height: imgH)
            } else {
                Text("No image selected")
            }
            
            // If no file is selected
            if imagePath == nil {
                showBrowseButton()
            }
            
            /*if imagePath != nil {
                Button("Print Image Path") {
                    print("Selected image path: \(imagePath ?? "")")
                }
            }*/
            
            if imagePath != nil {
                /*Slider(value: $imgW, in: 16...512, step: 16) {
                    Text("Size: \(Int(imgW))")
                }
                .padding(.horizontal)*/
                
                
                HStack {
                    Toggle("All", isOn: $isToggled_All)
                        .onChange(of: isToggled_All) {
                        //.onReceive([isToggled_All].publisher) {
                            newValue in
                        //Toggle("All", isOn: $isToggled_All).onAppear {
                            //if newValue {
                                isToggled_16 = newValue
                                isToggled_32 = newValue
                                isToggled_128 = newValue
                                isToggled_256 = newValue
                                isToggled_512 = newValue
                            //}
                        }
                    Toggle("16x16", isOn: $isToggled_16)
                    Toggle("32x32", isOn: $isToggled_32)
                }
                HStack {
                    Toggle("128x128", isOn: $isToggled_128)
                    Toggle("256x256", isOn: $isToggled_256)
                    Toggle("512x512", isOn: $isToggled_512)
                }
                
                HStack {
                    showBrowseButton()
                    Button("Generate .icns") {
                        //resizeAndSaveImage(imagePath: imagePath, width: imgW, height: imgW)
                        //print("Toggle 1 value: \(isToggled_16)")
                        if(isToggled_16 == true) {
                            //resizeAndSaveImage(imagePath: imagePath, width: 16, height: 16)
                            runShellCommand(res:16)
                        }
                        
                        if(isToggled_32 == true) {
                            runShellCommand(res:32)
                        }
                        
                        if(isToggled_128 == true) {
                            runShellCommand(res:128)
                        }
                        
                        if(isToggled_256 == true) {
                            runShellCommand(res:256)
                        }
                        
                        if(isToggled_512 == true) {
                            runShellCommand(res:512)
                        }
                    }
                    .padding(.maximum(0, 0))
                    .disabled(allTogglesOff)
                }
            }
            
            
            
            
            /*Button("Select Image") {
             let panel = NSOpenPanel()
             panel.allowedContentTypes = [.image]
             panel.canChooseFiles = true
             panel.canChooseDirectories = false
             panel.allowsMultipleSelection = false
             
             panel.begin {
             response in
             if response == NSApplication.ModalResponse.OK, let url = panel.urls.first {
             imagePath = url.path
             print("Selected image path: \(imagePath ?? "")")
             }
             }
             }*/
        }
    }
    
    func  showBrowseButton() -> some View {
        return Button("Select Image") {
            let panel = NSOpenPanel()
            //panel.allowedContentTypes = [.image]
            panel.allowedFileTypes = ["png", "jpg", "jpeg", "gif"]
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            
            panel.begin { response in
                if response == .OK, let url = panel.urls.first {
                    imagePath = url.path
                    urlg = url
                }
            }
        }
    }
    
    func runShellCommand(res: Int) {

        let process = Process()
         let escapedImagePath = imagePath!.replacingOccurrences(of: " ", with: "\\ ")
        //let escapedImagePath = imagePath?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)

        //let idd = escapedImagePath?.lastIndex(of: ".")
        //let fname = escapedImagePath.
        //let subi = escapedImagePath?[&idd...]
        
        let escapedImagePath2 = imagePath!.replacingOccurrences(of: ".\\w+$", with: "", options: .regularExpression).replacingOccurrences(of: " ", with: "\\ ")
        
        //let command = "sips -s format icns -z " + String(res) + " " + String(escapedImagePath) + " --out " + String(escapedImagePath2!) + "_" + String(res) + "x" + String(res) + ".icns"
        //let command = "sips -s format icns -z \(Int(res)) \(Int(res)) \(String(describing: escapedImagePath ?? "")) --out  \(String(describing: escapedImagePath2 ?? ""))\("_")\(String(res))\("x")\(String(res)).icns"
        let command = "sips -s format icns -z \(res) \(res) \(String(describing:escapedImagePath )) --out \(escapedImagePath2)_\(String(res))x\(String(res)).icns"
        
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        process.launch()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: outputData, encoding: .utf8) {
            outputText = output
        }
        
        process.waitUntilExit()
        
        // Second pass for setting preview image
        let command2 = "sips -i \(String(describing:escapedImagePath2 ))_\(String(res))x\(String(res)).icns \(String(describing:escapedImagePath2 ))_\(String(res))x\(String(res)).icns"
        
        let process2 = Process()
        process2.launchPath = "/bin/bash"
        process2.arguments = ["-c", command2]
        
        let outputPipe2 = Pipe()
        process2.standardOutput = outputPipe2
        
        process2.launch()
        
        let outputData2 = outputPipe2.fileHandleForReading.readDataToEndOfFile()
        if let output2 = String(data: outputData2, encoding: .utf8) {
            outputText2 = output2
        }
        
        process2.waitUntilExit()
    }
    
    private func resizeAndSaveImage(imagePath: String, width: CGFloat, height: CGFloat) {
        guard let image = NSImage(contentsOfFile: imagePath) else { return }
        
        let resizedImage = resizeImage(image: image, width: width, height: height)
        
        // Save the resized image
        let savePanel = NSSavePanel()
        //savePanel.allowedContentTypes = [.image]
        savePanel.allowedFileTypes = ["png", "jpg", "jpeg", "gif"]
        savePanel.nameFieldLabel = "Save Resized Image"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                if let data = resizedImage.tiffRepresentation,
                   let bitmapImage = NSBitmapImageRep(data: data) {
                    let jpegData = bitmapImage.representation(using: .jpeg, properties: [:])
                    try? jpegData?.write(to: url)
                    print("Image saved successfully.")
                }
            }
        }
    }
    
    private func resizeImage(image: NSImage, width: CGFloat, height: CGFloat) -> NSImage {
        let newSize = NSSize(width: width, height: height)
        let newImage = NSImage(size: newSize)
        
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: image.size), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()
        
        return newImage
    }
    
    func orderFrontStandardAboutPanel(_ sender: Any?) {
        
    }
}

@available(macOS 11.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            //.preferredColorScheme(.dark)
            .background(Color.black)

    }
}
