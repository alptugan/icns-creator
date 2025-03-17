<h1 align="center">icns Creator</h1>
<p align="center">A native Mac OS app that converts images to `.iconset` or `.icns` icon files.</p>
<!--p align="center">﹏﹏ ‿︵ ﹏﹏</p-->

<p align="center">・・・・・・・・・・ ༄ ・・・・・・・・・・</p> 

<p align="center">
Download the app from <a href="https://github.com/alptugan/icns-creator/releases/latest">Releases</a><br>(Requires minimum Mac OS 11.0 - 15.3.1).<br><span style="color:#ffcc00">PLEASE FOLLOW "Installation" instructions.</span>
</p>

<img src="assets/icns_creator_v3_cover.jpg" alt="Image shows the three different screen shots of the main app window." width="100%" height="auto" style="border-radius:15px;">

<p style="margin-top:20px" align="center">
<img src="./assets/logo.png" width="10%">
</p>

## DEMO & Instructions & QuickStart

The UI is a lot different with the v1. The following video is still appropriate. icns Creator is a macOS application that allows you to easily create icns files from any PNG or JPG image file. With this tool, you can quickly generate high-quality icns files to use as icons for your macOS applications or generate a single appropriate .iconset file. Codesigning is an headache for me! And I do not want to pay for an app that I release as open-source. You can review the code, if you have concerns about the app. Or simply, you can choose not to use the app 🖖🏻.

[<img src="icns%20creator/yt_cover_2.png" width="100%">](https://youtu.be/nwUu_3UDWjM "Now in Mac OS")


## Features

- Simple and intuitive user interface.
- Support for GIF, PNG and JPG image formats.
- Automatic generation of icns files in variable sizes.
- iconset folder and individual .icns file generation.
- Options to set icon style for Apple design standarts (subtle shadow, corner radius, icon margin area).

## Installation

### Option 1 (Recommended for non-developers)
To use icns Creator, follow these steps:

1. Download the latest release from the [Releases](https://github.com/alptugan/icns-creator/releases) page. 
2. Since the app is not signed by Apple, your OS does not open the app.You must enable System Settings->Privacy & Security->Security->App Store and identified developers option. Depending on your configuration, you need to disable "Gate keeper" option to install unsigned apps. You can have more information [link](https://www.makeuseof.com/how-to-disable-gatekeeper-mac/)
3. Unzip the file. DO NOT DOUBLE CLICK. Right-click on icns Creator application file (`icns-creator.app`) to run it.
3. If prompted, allow the application to run on your system.
4. You're ready to start creating icns files out of PNG, JPG, or any other image document!


### Option 2 (For developers)
To build the app by yourself or make modifications on the source code (Optional). If you have issues because of Apple's security issues, or you do not prefer to install compiled apps, you can compile the app by yourself and review the code as well.

1. Install XCode application from Appstore.
2. Download or clone the repository.
<p style="margin-bottom:20px" align="center">
    <img src="./assets/icns_dev_tut1.jpeg" width="80%">
</p>

3. Unzip the folder and Double-click `icns creator.xcodeproj` file to open it in XCode.
<p style="margin-bottom:20px" align="center">
    <img src="./assets/icns_dev_tut2.jpeg" width="80%">
</p>

4. Hit `Run` button to compile the project.
<p style="margin-bottom:20px" align="center">
    <img src="./assets/icns_dev_tut3.jpeg" width="80%">
</p>

5. If everything goes well hopefully, you can find the app under the XCode's Product menu.
<p style="margin-bottom:20px" align="center">
    <img src="./assets/icns_dev_tut4.png" width="80%">
</p>

## Usage for Designers & Developers

1. Prepare your image file in your preferred image editor, ensuring it has a minimum size of 1024x1024 pixels.
2. Save the image file as a PNG or JPG file in a 1:1 aspect ratio for the best results.
3. Open the icns Creator application.
4. Click the `Browse` button or drag & drop the image.
5. `.iconset` tab creates a single icon file, or `.icns` tab creates individual .icns files required for html pages.
6. By default shadow, rounded corners and padding for the generated icon is enabled. For recent Mac OS standards, you should enable all of the options to apply Apple Design standarts. If you just want to generate .icns files as before, disable all of the options.
7. The files will be created in the same directory as the original image file.


## Contribution

Contributions to icns Creator are welcome! If you would like to contribute to the project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with descriptive commit messages.
4. Do not delete commented codes please 😉
4. Push your changes to your forked repository.
5. Open a pull request in the main repository, explaining your changes and their benefits.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=alptugan/icns-creator&type=Date)](https://star-history.com/#alptugan/icns-creator&Date)

## License

icns Creator is released under the [MIT License](https://opensource.org/licenses/MIT). See the [LICENSE](https://github.com/alptugan/icns-creator/blob/main/LICENSE.md) file for more information.

## Acknowledgements

- The icns Creator app was inspired by the need for a simple and efficient tool to create icns files for macOS applications. 


## Contact

If you have any questions, suggestions, or feedback, please feel free to use Issues section.

_________________________________________________

## To do 
- [x] ~~App release~~
- [x] ~~Make it compatible with min Mac OS 11.0~~
- [x] ~~Drag & drop design files onto the app window.~~
- [x] ~~Release major v2.~~
- [x] ~~Add feature to export icons with rounded-corners.~~ 
- [x] ~~Add feature to export icons with padding depending on Apple design standards.~~
- [x] ~~Add feature to export icons with shadow option.~~ 
- [x] ~~Set original icon~~
- [x] ~~Delete PNG file after creation of the individual .icns files~~
- [x] ~~Ask for destination to save files...~~
- [x] ~~Better UI to show switch toggle options~~
- [x] ~~Release major v3~~
- [x] ~~Improve documentation on compiling the project.~~
- [x] ~~Check the latest release on a Intel-based Mac (Rosetta Architecture may help to fix issues for Intel chip).~~
- [x] ~~Add preview for changed options~~
- [x] ~~Destination path dialog~~
- [ ] ‼️ Set options for rounded corners: None, Rounded, Circular
- [ ] ‼️ Update YouTube video tutotial.
- [ ] ‼️ File name issue. When there is blank space in filename, the process fails. `code solid.svg` - failed. `code-solid.svg` - success.
- [ ] Optional: A workaround for testing, and permissions. Test the app on a fresh Mac.
- [ ] v4
    - [ ] Drag & drop folders or apps to edit their icns props on the fly for better UX. 
    - [ ] Set the icons using the app.
    - [ ] Return to original icon option.
    - [ ] Keep the original icon in the original app directory.
- [ ] Optional: Distrubute image conversion process into different CPU threads. It is a possible fix to avoid locking main thread during the icns creation process.
- [ ] Optional: Distrubute through Homebrew or any other package manager.
- [ ] Optional: Apple Codesign issues! (Will exist forever because of Apple's buggy developer registration process) 
