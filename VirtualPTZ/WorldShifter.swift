//
//  WorldShifter.swift
//  VirtualPTZ
//
//  Created by Georg Klein on 31.05.21.
//  Copyright © 2021 Kleinware.net. All rights reserved.
//

import Foundation
import SceneKit
import AVKit
import GameController

class WorldShifter {
    var sceneView : SCNView
    var worldSceneSingleton: WorldScene
    var worldScene : SCNScene
    var cameraNode : SCNNode
    var pitch = CGFloat(0)
    var yaw = CGFloat(0)
    var roll = CGFloat(0)
    var fov = CGFloat(60)
    
    var gcs = GCController.controllers()
    var hasGameController = false
    var isLiveCamRunning = false
    var isCameraAccessAllowed = false
    var gc : GCController
    
    init(width: CGFloat, height: CGFloat) {
        log("WorldShifter initialized with width \(width) and height \(height)")
        sceneView = SCNView(frame: NSRect(x: CGFloat(0), y: CGFloat(0), width: width, height: height))
        worldSceneSingleton = WorldScene()
        worldScene = worldSceneSingleton.scene
        cameraNode = worldScene.rootNode.childNode(withName:"camera", recursively: false)!
        if( gcs.count > 0 ) {
            log("Found \(gcs.count) gamecontrollers, using first to control PTZ")
            gc = gcs[0]
            hasGameController = true
        }
        else {
            gc = GCController()
            log("No gamecontrollers found")
        }
        scnScene()
        NotificationCenter.default.addObserver(self, selector: #selector(WorldShifter.handleControllerDidConnectNotification(notification:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WorldShifter.handleControllerDidDisonnectNotification(notification:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        sceneView.play(nil)
        log("WorldShifter initialized, running status: \(sceneView.isPlaying)")
    }
    
    func checkForInput() {
        if( hasGameController ) {
            let leftThumbstick = gc.extendedGamepad?.leftThumbstick
            yaw -= CGFloat((leftThumbstick?.xAxis.value)!/64)
            pitch -= CGFloat((leftThumbstick?.yAxis.value)!/64)
            let rightThumbstick = gc.extendedGamepad?.rightThumbstick
            roll += CGFloat((rightThumbstick?.xAxis.value)!/16)
            fov -= CGFloat((rightThumbstick?.yAxis.value)!)
            let menu = (gc.extendedGamepad?.buttonMenu)!
            if( menu.isPressed ) {
                log("Menu button pressed")
                roll = CGFloat(0)
                yaw = CGFloat(0)
                pitch = CGFloat(0)
                fov = 60
            }
        }
        if( isLiveCamRunning == false ) {
            activateLiveCam()
        }
        cameraNode.eulerAngles = SCNVector3(pitch,yaw,roll)
        cameraNode.camera?.fieldOfView = fov
    }
    
    func scnScene() {//coordinator: Coordinator) {
        log("Trying to update sceneView with data")
        sceneView.scene = worldScene
        sceneView.pointOfView = cameraNode
//        sceneView.delegate = coordinator
        
        log("Changing cameraNode position")
        cameraNode.position = SCNVector3(0,0,0)
        log("Changing SphereNode position")
        worldScene.rootNode.childNode(withName: "sphere", recursively: false)?.position = SCNVector3(0,0,0)

        log("Updating scene with liveCam material")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                log("User has already authorized camera access, trying to activate")
                isCameraAccessAllowed = true
                activateLiveCam()
            case .notDetermined: // The user has not yet been asked for camera access.
                log("First time running, asking for camera access")
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        log("User granted camera access, trying to activate")
                        self.isCameraAccessAllowed = true
                        self.activateLiveCam()
                    }
                }
                return
        case .denied:
            log("User denied access to liveCam")
            break // The user has previously denied access.
        case .restricted:
            log("User is not allowed to grant access to liveCam")
            break // The user can't grant access due to restrictions.
        @unknown default:
            log("Something unexpected happened, bailing out")
            break
        }
        return
    }
    
    func activateLiveCam() {
        let externalCameras = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.externalUnknown], mediaType: .video, position: .unspecified).devices
        var liveCam = externalCameras[0]    // default is first found
        for currentDevice in externalCameras {
            log( "Looking for THETA, current camera is \(currentDevice.localizedName)")
            if( currentDevice.localizedName.contains("THETA")) {
                liveCam = currentDevice
                log("Found THETA camera, supported formats:")
                for curFormat in liveCam.formats {
                    log("Format \(curFormat.description) description: \(curFormat.formatDescription)")
                }
                NotificationCenter.default.addObserver(self, selector: #selector(WorldShifter.handleAVCaptureDeviceWasConnectedNotification(notification:)), name: NSNotification.Name.AVCaptureDeviceWasConnected, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(WorldShifter.handleAVCaptureDeviceWasDisconnectedNotification(notification:)), name: NSNotification.Name.AVCaptureDeviceWasDisconnected, object: nil)
                isLiveCamRunning = true
            }
        }
        if( liveCam.isConnected && isLiveCamRunning ) {
            log("LiveCam found, uses device \(liveCam.localizedName)")
            do {
                try
                liveCam.lockForConfiguration()
//                liveCam.activeFormat = liveCam.formats[1]
                liveCam.unlockForConfiguration()
            } catch {
                log("LiveCam configuration failed")
            }
            let sphere = worldScene.rootNode.childNode(withName: "sphere", recursively: false)
            let material = sphere?.geometry?.material(named: "bluescreen")
            material?.diffuse.contents = liveCam
        }
    }
    
    @objc func handleControllerDidConnectNotification(notification: NSNotification) {
        gc = GCController.controllers()[0]
        hasGameController = true
        log("New controller connected: \(notification.name)")
    }
    @objc func handleControllerDidDisonnectNotification(notification: NSNotification) {
        log("Controller disconnected")
        hasGameController = false
    }
    
    @objc func handleAVCaptureDeviceWasConnectedNotification(notification: NSNotification) {
        if( (isLiveCamRunning == false) && (isCameraAccessAllowed == true) ) {
            activateLiveCam()
        }
    }

    @objc func handleAVCaptureDeviceWasDisconnectedNotification(notification: NSNotification) {
        if( isLiveCamRunning == true ) {
            log("A camera device was disconnected, check if it is the PTZ source cam")
            let sphere = worldScene.rootNode.childNode(withName: "sphere", recursively: false)
            let material = sphere?.geometry?.material(named: "bluescreen")
            let liveCam = (material?.diffuse.contents) as! AVCaptureDevice
            if( notification.object as! AVCaptureDevice == liveCam ) {
                log("VirtualPTZ sourcecam lost connecting, waiting for camera to reconnect")
                isLiveCamRunning = false
                material?.diffuse.contents = NSColor(named: "blue")
            }
        }
    }

}
