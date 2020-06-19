//
//  DeviceListView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//
import Foundation
import SwiftUI

struct DeviceListView: View {
    var deviceArray: [SearchedDevice]
    var credentials: Credentials
    var setIsLoading: (Bool) -> Void
    var setErrorDescription: (String) -> Void
    
    var body: some View {
        List {
            ForEach(deviceArray, id: \.self) { device in
                NavigationLink(destination: DeviceDetailView(deviceDetailViewModel: DeviceDetailViewModel(searchedDevice: device, deviceType: device.deviceType, credentials: self.credentials, setIsLoading: self.setIsLoading, setErrorDescription: self.setErrorDescription)))
                {
                    DeviceRow(device: device, credentials: self.credentials)
                }
            }
        }
    }
}

//struct DeviceListView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceListView(deviceArray: [SearchedDevice](), credentials: Credentials(username: "", password: "", server: URLComponents()))
//    }
//}


struct DeviceRow: View {
    var device: SearchedDevice
    var credentials: Credentials
    
    var body: some View {
        HStack {
            DeviceImage(device.isiOS)
            Text(device.name ?? "")
            Text(device.serialNumber ?? "")
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

//struct DeviceRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceRow(device: SearchedDevice(id: 1), credentials: Credentials(username: "", password: "", server: URLComponents()))
//    }
//}
