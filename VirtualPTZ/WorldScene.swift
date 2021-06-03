//
//  WorldScene.swift
//  SceneKit Test
//
//  Created by Georg Klein on 01.06.21.
//

import Foundation
import SceneKit

class WorldScene {
    let scene = SCNScene()
    let devices = MTLCopyAllDevices()
    var renderer : SCNRenderer

    init() {
        // Set up basic geometry
        let sphere = SCNSphere(radius: CGFloat(100.0))
        sphere.segmentCount = 360
        sphere.name = "sphere"
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.name = "sphere"

        // Add material
        let material = SCNMaterial()
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
        material.diffuse.magnificationFilter = .nearest
        material.cullMode = .back
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1,-1,1)
        material.isDoubleSided = true
        material.name = "bluescreen"
        
        sphere.firstMaterial = material
        scene.rootNode.addChildNode(sphereNode)

        // Add camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(CGFloat(0),CGFloat(0),CGFloat(0))
        cameraNode.camera?.projectionDirection = .horizontal
        cameraNode.camera?.fieldOfView = CGFloat(60)
        cameraNode.name = "camera"
        scene.rootNode.addChildNode(cameraNode)

        if( devices.count > 0 ) {
            renderer = SCNRenderer(device: devices[0], options: nil)
        }
        else {
            log("No suitable rendering devices found")
            renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
        }
        renderer.scene = scene
    }
}
