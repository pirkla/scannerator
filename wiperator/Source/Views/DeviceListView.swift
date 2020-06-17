//
//  DeviceListView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct DeviceListView: View {
    var deviceArray: [SearchedDevice]
    var credentials: Credentials
    
    var body: some View {
            List(deviceArray) { device in
                NavigationLink(destination: DeviceDetailView(deviceDetailViewModel: DeviceDetailViewModel(searchedDevice: device, deviceType: device.deviceType, credentials: self.credentials)))
                {
                DeviceRow(device: device, credentials: self.credentials)
                }
            }
    }
}

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView(deviceArray: [SearchedDevice](), credentials: Credentials(username: "", password: "", server: URLComponents()))
    }
}


struct DeviceRow: View {
    var device: SearchedDevice
    var credentials: Credentials
    
    var body: some View {
        HStack {
            DeviceImage(device.isiOS)
//            CheckedInImage(device.isCheckedIn)
            Text(device.name ?? "")
            Text(device.assetTag ?? "")
        }
    }
    func CheckedInImage(_ isCheckedIn: Bool) -> Image {
        if isCheckedIn {
            return Image(systemName: "tray.and.arrow.down.fill")
        }
        else {
            return Image(systemName: "tray.and.arrow.up.fill")
        }
    }
    func DeviceImage(_ isiOS: Bool) -> AnyView {
        if isiOS {
            return AnyView(Image(systemName: "rectangle")
                .rotationEffect(Angle(degrees: 90)))
        }
        else {
            return AnyView(Image(systemName: "desktopcomputer"))
        }
    }

}

struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(device: SearchedDevice(id: 1, name: nil, udid: nil, serialNumber: nil, macAddress: nil, altMacAddress: nil, assetTag: nil, barCode1: nil, barCode2: nil, username: nil, realName: nil, email: nil, emailAddress: nil, room: nil, position: nil, building: nil, buildingName: nil, department: nil, departmentName: ""), credentials: Credentials(username: "", password: "", server: URLComponents()))
    }
}
