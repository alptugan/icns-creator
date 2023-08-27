//
//  ContentView.swift
//  icns creator
//
//  Created by alp tugan on 10.08.2023.
//

import SwiftUI

class WindowSize: ObservableObject {
    @Published var size: CGSize = .zero
}

struct ContentView: View {
    @State private var isToggled_All = true
    @State private var isToggled_16 = true
    @State private var isToggled_32 = true
    @State private var isToggled_128 = true
    @State private var isToggled_256 = true
    @State private var isToggled_512 = true
    @State private var imagePath: String?
    @State private var imgW: CGFloat = 150
    @State private var imgH: CGFloat = 150
    @State private var urlg:URL?
    
    @State private var outputText = ""
    @State private var outputText2 = ""
    
    @State private var dragOver : Bool = false
    @State private var selectedImage = NSImage(named: "image")
    @StateObject private var win = WindowSize()
    
    var allTogglesOff: Bool {
        return !isToggled_All && !isToggled_16 && !isToggled_32 && !isToggled_128 && !isToggled_256 && !isToggled_512
    }
    
    var body: some View {
        
        
        GeometryReader { geo in
            ZStack (alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .frame(width:280,height: 250,alignment: Alignment.top)
                    .overlay(
                        Group {
                            GeometryReader { geometry in
                                // dash line around the drop location
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(dragOver ? Color.blue : Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 3, dash:[4]))
                                    .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.85)
                                    .background(dragOver ? Color.blue.opacity(0.1) : Color.white) // If nothing dragged onto section
                                    .cornerRadius(10)
                                    .position(x: geometry.frame(in: .local).midX, y:geometry.frame(in: .local).midY)
                                
                                VStack {
                                    //Spacer()
                                    // If the image is selected
                                    if selectedImage != nil {
                                        GeometryReader { geo in
                                            let localFrame = geo.frame(in: .local)
                                            VStack {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 14)
                                                    //.stroke(Color.blue, style: StrokeStyle(lineWidth: 4))
                                                        .frame(width: imgW , height: imgH)
                                                        .shadow(radius: 10)
                                                    //.background(Color.blue) // If nothing dragged onto section
                                                    //.cornerRadius(13)
                                                    //.position(x: selectedImage.frame(in: .local).midX, y:selectedImage.frame(in: .local).midY)
                                                    
                                                    Image(nsImage: selectedImage!)
                                                        .resizable()
                                                    //.aspectRatio(contentMode: .fit)
                                                        .scaledToFit()
                                                        .frame(width: imgW, height: imgH)
                                                        .cornerRadius(15)
                                                }.position(x:localFrame.midX, y: localFrame.maxY)
                                            }
                                        }
                                    }
                                    
                                    // If no image is selected
                                    if selectedImage == nil {
                                        ZStack {
                                            GeometryReader { geo in
                                                let localFrame = geo.frame(in: .local)
                                                Image("imgcolor")
                                                    .resizable()
                                                    .scaleEffect(dragOver ? 1 : 0)
                                                    .position(x:dragOver ? localFrame.midX : localFrame.midX, y: localFrame.maxY - 20)
                                                
                                                /*Image("imgcolor")
                                                 .resizable()
                                                 .position(x:dragOver ? localFrame.minX : localFrame.midX, y: localFrame.midY)
                                                 
                                                 Image("imgcolor")
                                                 .resizable()
                                                 .position(x:dragOver ? localFrame.maxX : localFrame.midX, y: localFrame.midY)*/
                                                
                                                Image("drag")
                                                    .resizable()
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .position(x: localFrame.midX + 10, y: dragOver ? localFrame.maxY  : localFrame.maxY - 15)
                                                    .opacity(dragOver ? 0 : 1)
                                            }
                                        }.frame(width: imgW, height: imgH)
                                        
                                        //Text("No image selected")
                                        //showBrowseButton()
                                    }
                                    
                                    // Display the text always
                                    //Spacer()
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
                                        }.position(x:localFrame.midX, y: localFrame.maxY + 25)
                                    }
                                    
                                    
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    ) // Inside The content
                    .onDrop(of: ["public.file-url"], isTargeted: $dragOver.animation()) { providers in
                        
                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, error in
                            
                            if let imageData = data, let path = NSString(data: imageData, encoding: 4),
                               let url = URL(string: path as String) {
                                
                                let image = NSImage(contentsOf: url)
                                DispatchQueue.main.async {
                                    self.selectedImage = image
                                }
                            }
                            
                        })
                        return true
                    } // Show dropped image
                    .onTapGesture {
                        self.selectFileFromSystem()
                    } // Show Browse window
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: Alignment.top)
            .background(Color.blue.opacity(0.008))
            .position(x: win.size.width*0.5, y:130)
            .onAppear {
                win.size = geo.size
                print("Initial Window Size: \(win.size.width) x \(win.size.height)")
            }
        }.environmentObject(win)
        
        Spacer()
            .frame(height:150)

        // After the image is display in the container show Convert Button
        VStack (alignment: .center) {
            if selectedImage != nil {
                HStack {
                    Toggle("All", isOn: $isToggled_All)
                        .onChange(of: isToggled_All) {
                            newValue in
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
                } // Toggle buttons first row
                HStack {
                    Toggle("128x128", isOn: $isToggled_128)
                    Toggle("256x256", isOn: $isToggled_256)
                    Toggle("512x512", isOn: $isToggled_512)
                } // Toggle buttons second row
                HStack {
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
                    .disabled(allTogglesOff)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func selectFileFromSystem() {
        NSOpenPanel.openImage { result, url in
            if case let .success(image) = result {
                self.selectedImage = image
                self.imagePath = url?.path
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
                    selectedImage = NSImage(contentsOfFile: imagePath!)
                }
            }
        }
    }
}

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //.preferredColorScheme(.dark)
            .background(Color.black)
    }
}
