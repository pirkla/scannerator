//
//  DeviceDetailView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/7/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct DeviceDetailView: View {
    @State private var showCheckin = false
    @State private var showWipe = false
    @ObservedObject var deviceDetailViewModel: DeviceDetailViewModel
    
    var body: some View {
      VStack {
        VStack {
            Text(deviceDetailViewModel.searchedDevice.name ?? "").font(.title)
            Text(deviceDetailViewModel.searchedDevice.serialNumber ?? "").font(.headline)
            Text(deviceDetailViewModel.device?.assetTag ?? " ")
                .padding(.bottom, 10.0)
            deviceDetailViewModel.managedStatusView()
            deviceDetailViewModel.checkinStatusView().padding(.bottom, 20.0)
        }
        HStack {
            deviceDetailViewModel.wipeView($deviceDetailViewModel.showModal)
                .scaleEffect(showWipe ? 1 : 0)
                .animation(.easeInOut)
                .onAppear {
                self.showWipe = true
            }
            deviceDetailViewModel.checkedInView()
                .scaleEffect(showCheckin ? 1 : 0)
                .animation(.easeInOut)
                .onAppear {
                self.showCheckin = true
            }
        }
        Spacer()
      }
      .onAppear {
        self.deviceDetailViewModel.updateDevice()
        }
    }
}

//struct DeviceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceDetailView(deviceDetailViewModel: DeviceDetailViewModel(searchedDevice: SearchedDevice(id: 1), deviceType: Computer.self, credentials: Credentials()))
//    }
//}

