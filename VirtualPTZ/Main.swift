//
//  Main.swift
//  VirtualPTZ
//
//
//  Copyright © 2021 Kleinware.net. All rights reserved.
//  Based on SimpleDALPlugin by com.seanchas116 (which is in turn based on John Boile's Objective-C code

import Foundation
import CoreMediaIO

@_cdecl("virtualPTZMain")
public func virtualPTZMain(allocator: CFAllocator, requestedTypeUUID: CFUUID) -> CMIOHardwarePlugInRef {
    NSLog("VirtualPTZMain")
    return pluginRef
}
