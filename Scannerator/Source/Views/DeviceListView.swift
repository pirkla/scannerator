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
    // function to control loading icon in parent view
    var setIsLoading: (Bool) -> Void
    // function to control error sheet view in parent view
    var setErrorDescription: (String) -> Void
    
    var body: some View {
        List {
            // foreach is used so we can calculate by hash instead of identifiable. This prevents some issues with new rows thinking they're old rows and not updating the child view
            ForEach(deviceArray, id: \.self) { device in
                NavigationLink(destination: DeviceDetailView(deviceDetailViewModel: DeviceDetailViewModel(searchedDevice: device, deviceType: device.deviceType, credentials: self.credentials, setIsLoading: self.setIsLoading, setErrorDescription: self.setErrorDescription)))
                {
                    DeviceRow(device: device)
                }
            }
        }
    }
}

struct DeviceRow: View {
    var device: SearchedDevice
    
    var body: some View {
        HStack {
            DeviceImage(device.isiOS)
            Text(device.name ?? "")
            Text(device.serialNumber ?? "")
        }
    }

    // calculate image to use for device's icon
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
