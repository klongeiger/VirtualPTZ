# VirtualPTZ

This is a DAL-Plugin that turns a 360° webcam into a virtual PTZ (Pitch/Tilt/Zoom) camera by choosing a variable segment of the original camera view and transforming it into a virtual camera output.
Based on [seanchas116/SimpleDALPlugin](https://github.com/seanchas116/SimpleDALPlugin)
which is based on [johnboiles/coremediaio-dal-minimal-example](https://github.com/johnboiles/coremediaio-dal-minimal-example)
who himself used [Apple's CoreMediaIO example](https://developer.apple.com/library/archive/samplecode/CoreMediaIO/Introduction/Intro.html)!)


## How to run

* Build VirtualPTZ in Xcode
* Copy VirtualPTZ.plugin into `/Library/CoreMediaIO/Plug-Ins/DAL`
* Connect your 360° cam and start it
* Attach gamecontroller and connect
* Open Webcam-using app and choose VirtualPTZ as camera input
* Control the camera view with left thumbstick, control zoom and roll with right thumbstick of gamecontroller

There are some (severe) limitations and drawbacks right now:
* As I could only test it with my own 360° cam, selection of the source camera is currently hardcoded to Ricoh Theta cameras (specifically the THETA V, though others should work). I would be open to test this with other cameras if someone provided (*cough RICOH*) me with examples.
* I couldn't be bothered to implement keyboard controls, so a gamecontroller is required right now
* Resolution is pretty bad, which (depending on you use case) may make this project useless. 
* Debugging or profiling plugins is a nightmare, so this may contain crashing bugs and memory leaks galore. 
