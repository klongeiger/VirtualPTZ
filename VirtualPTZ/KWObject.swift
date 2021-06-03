//
//  Object.swift
//  VirtualPTZ
//
//
//  Copyright © 2021 Kleinware.net. All rights reserved.
//  Based on SimpleDALPlugin by com.seanchas116 (which is in turn based on John Boile's Objective-C code

import Foundation

protocol KWObject: AnyObject {
    var objectID: CMIOObjectID { get }
    var properties: [Int: Property] { get }
}

extension KWObject {
    func hasProperty(address: CMIOObjectPropertyAddress) -> Bool {
        return properties[Int(address.mSelector)] != nil
    }

    func isPropertySettable(address: CMIOObjectPropertyAddress) -> Bool {
        guard let property = properties[Int(address.mSelector)] else {
            return false
        }
        return property.isSettable
    }

    func getPropertyDataSize(address: CMIOObjectPropertyAddress) -> UInt32 {
        guard let property = properties[Int(address.mSelector)] else {
            return 0
        }
        return property.dataSize
    }

    func getPropertyData(address: CMIOObjectPropertyAddress, dataSize: inout UInt32, data: UnsafeMutableRawPointer) {
        guard let property = properties[Int(address.mSelector)] else {
            return
        }
        dataSize = property.dataSize
        property.getData(data: data)
    }

    func setPropertyData(address: CMIOObjectPropertyAddress, data: UnsafeRawPointer) {
        guard let property = properties[Int(address.mSelector)] else {
            return
        }
        property.setData(data: data)
    }
}

var objects = [CMIOObjectID: KWObject]()

func addObject(object: KWObject) {
    objects[object.objectID] = object
}
