//
//  DeviceDetailViewModel.swift
//  Scannerator
//
//  Created by Andrew Pirkl on 6/16/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import SwiftUI

class DeviceDetailViewModel: ObservableObject {
    @Published var showModal = false
    @Published var searchedDevice: SearchedDevice
    @Published var device: Device?
    @Published var deviceType: Device.Type
//    @Published var isLoading: Bool = true
    let credentials: Credentials
    var setIsLoading: (Bool) -> Void
    
    init(searchedDevice: SearchedDevice, deviceType: Device.Type, credentials: Credentials, setIsLoading: @escaping (Bool)->Void) {
        self.searchedDevice = searchedDevice
        self.deviceType = deviceType
        self.credentials = credentials
        self.setIsLoading = setIsLoading
    }
    
    func updateCheckin(_ checkinInt: Int) {
        
        deviceType.updateRequest.self(baseURL: self.credentials.server,checkinInt: checkinInt, id: self.searchedDevice.id, credentials: self.credentials.basicCreds, session: URLSession.shared) {
            result in
            self.updateDevice()
            switch result {
            case .success(let deviceResponse):
                print(String(data: deviceResponse, encoding: .utf8) as Any)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func wipeView(_ showModal: Binding<Bool>) -> AnyView? {
        if !searchedDevice.isiOS ||  device == nil {
            return nil
        }
        return AnyView(Button(action: {
            self.showModal = true
        }) {
            HStack {
                Image(systemName: "trash")
                    .padding([.top, .leading, .bottom], 10.0)
                Text("Wipe Device")
                    .padding([.top, .bottom, .trailing], 10.0)
            }
            .background(Color.init("TextBackground"))
        }.sheet(isPresented: showModal) {
            OptionSheet(title: "Wiping: \(self.searchedDevice.name ?? "Unknown")", description: "Are you sure?") { choice in
                if choice {
                    guard let device = self.device else {
                        return
                    }
                    self.deviceType.wipeRequest.self(baseURL: self.credentials.server, id: device.id, passcode: nil, credentials: self.credentials.basicCreds, session: URLSession.shared) {
                            result in
                            switch result {
                            case .success(let deviceResponse):
                                print(String(data: deviceResponse, encoding: .utf8) as Any)
                            case .failure(let error):
                                print(error)
                            }
                    }
                }
            }
        }
        .cornerRadius(10)
        .disabled(device?.managed != true)
        )
    }


    func checkedInView() -> AnyView?{
        let checkInbutton = Button(action: {
            self.updateCheckin(1)
        }) {
            HStack {
                Image(systemName: "rectangle.badge.checkmark")
                    .padding([.top, .leading, .bottom], 10.0)
                Text("Check In")
                    .padding([.top, .bottom, .trailing], 10.0)
            }
            .background(Color.init("TextBackground"))
        }
        .cornerRadius(10)

        let checkOutButton = Button(action: {
            self.updateCheckin(0)
        }) {
            HStack {
                Image(systemName: "rectangle.badge.xmark")
                    .padding([.top, .leading, .bottom], 10.0)
                Text("Check Out")
                    .padding([.top, .bottom, .trailing], 10.0)
            }
                .background(Color.init("TextBackground"))
        }
            .cornerRadius(10)

        guard device != nil else {
            return nil
        }
        guard let isCheckedIn = device?.isCheckedIn else {
            return AnyView(HStack {
                checkOutButton
                checkInbutton
            })
        }
        if isCheckedIn {
            return AnyView(checkOutButton)
        }
        else {
            return AnyView(checkInbutton)
        }
    }

    func updateDevice() {
//        DispatchQueue.main.async {
//            self.isLoading = true
//        }
        self.setIsLoading(true)
        deviceType.deviceRequest.self(baseURL: self.credentials.server, id: self.searchedDevice.id, credentials: self.credentials.basicCreds, session: URLSession.shared) {
            result in
            switch result {
            case .success(let deviceResponse):
                DispatchQueue.main.async {
                    self.setIsLoading(false)
//                    self.isLoading = false
                    self.device = deviceResponse
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    
}
