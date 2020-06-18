//
//  SearchedDevice.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/14/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation



struct SearchedDevice: Codable, Identifiable {
    var uuid = UUID()
    var id : Int
    var name: String?
    var udid: String?
    var serialNumber: String?
    var macAddress: String?
    var altMacAddress: String?
    var assetTag: String?
    var barCode1: String?
    var barCode2: String?
//    var username: String?
//    var realName: String?
//    var email: String?
//    var emailAddress: String?
//    var room: String?
//    var position: String?
//    var building: String?
//    var buildingName: String?
//    var department: String?
//    var departmentName: String?
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case udid
        case serialNumber
        case macAddress
        case altMacAddress
        case assetTag
        case barCode1
        case barCode2
    }
    
}
// todo: UGH this is a hack and liable to fail one day with an update to the api. probably not though
extension SearchedDevice {
    
    init(id: Int){
        self.id = id
    }
    
    var isiOS: Bool {
        get {
            return barCode2 == nil
        }
    }
    var deviceType: Device.Type {
        if isiOS {
            return MobileDevice.self
        }
        return Computer.self
    }
}

extension SearchedDevice: Hashable {
    static func == (lhs: SearchedDevice, rhs: SearchedDevice) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
