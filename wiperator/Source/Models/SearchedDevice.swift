//
//  SearchedDevice.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/14/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

protocol SearchedDevice: Codable {
    var id : Int {get }
    var name: String? {get }
    var udid: String? {get }
    var serialNumber: String? {get }
    var macAddress: String? {get }
    var altMacAddress: String? {get }
    var assetTag: String? {get }
    var barCode1: String? {get }
    var barCode2: String? {get }
    var username: String? {get }
    var realName: String? {get }
    var email: String? {get }
    var emailAddress: String? {get }
    var room: String? {get }
    var position: String? {get }
    var building: String? {get }
    var buildingName: String? {get }
    var department: String? {get }
    var departmentName: String? {get }
    var osValue: OSValue {get }
}

enum OSValue {
    case computer
    case mobileDevice
}

