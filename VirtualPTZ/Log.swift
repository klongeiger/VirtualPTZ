//
//  Log.swift
//  VirtualPTZ
//
//
//  Copyright © 2021 Kleinware.net. All rights reserved.
//  Based on SimpleDALPlugin by com.seanchas116 (which is in turn based on John Boile's Objective-C code

import Foundation

func log(_ message: Any = "", function: String = #function) {
    NSLog("VirtualPTZ: \(function): \(message)")
}
