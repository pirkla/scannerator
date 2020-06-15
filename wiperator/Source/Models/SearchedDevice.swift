//
//  SearchedDevice.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/14/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation



struct SearchedDevice: Codable, Identifiable {
    var id : Int
    var name: String?
    var udid: String?
    var serialNumber: String?
    var macAddress: String?
    var altMacAddress: String?
    var assetTag: String?
    var barCode1: String?
    var barCode2: String?
    var username: String?
    var realName: String?
    var email: String?
    var emailAddress: String?
    var room: String?
    var position: String?
    var building: String?
    var buildingName: String?
    var department: String?
    var departmentName: String?
}
// todo: UGH this is a hack and liable to fail one day with an update to the api
extension SearchedDevice {
    var osValue: OSValue {
        get {
            return barCode2 == nil ? .mobileDevice : .computer
        }
    }
}

enum OSValue {
    case computer
    case mobileDevice
}
//

