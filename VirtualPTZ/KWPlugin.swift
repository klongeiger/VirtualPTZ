//
//  Plugin.swift
//  VirtualPTZ
//
//
//  Copyright © 2021 Kleinware.net. All rights reserved.
//  Based on SimpleDALPlugin by com.seanchas116 (which is in turn based on John Boile's Objective-C code

import Foundation

class KWPlugin: KWObject {
    var objectID: CMIOObjectID = 0
    let name = "VirtualPTZ"

    lazy var properties: [Int : Property] = [
        kCMIOObjectPropertyName: Property(name),
    ]
}
