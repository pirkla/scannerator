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
        // stack for device info
        VStack {
            //button to show device name and link to device's details page in Jamf Pro
            Button(action: {
                guard let myUrl = self.deviceDetailViewModel.deviceUrl() else {
                    self.deviceDetailViewModel.setErrorDescription("Could not find url")
                    return
                }
                UIApplication.shared.open(myUrl)
            }) {
                HStack {
                    Text(deviceDetailViewModel.searchedDevice.name ?? "").font(.title)
                }.padding(.all, 7.0)
            }
            .frame(alignment: .trailing)
            .background(Color.init("TextBackground"))
            .cornerRadius(10)
            .shadow(color:.black, radius: 3,x: 1, y: 1)
            
            // show serial number
            Text(deviceDetailViewModel.searchedDevice.serialNumber ?? "").font(.headline).padding(.top, 5)
            // show asset tag
            Text(deviceDetailViewModel.device?.assetTag ?? " ")
                .padding(.bottom, 10.0)

            // calculate managment status view
            deviceDetailViewModel.managedStatusView()
            // calculate checkin status view
            deviceDetailViewModel.checkinStatusView().padding(.bottom, 20.0)
        }
        
        // action button stack
        HStack {
            // calcualate wipe button
            deviceDetailViewModel.wipeView($deviceDetailViewModel.showModal)
                .shadow(color:.black, radius: 3,x: 1, y: 1)
                .scaleEffect(showWipe ? 1 : 0)
                .animation(.easeInOut)
                .onAppear {
                self.showWipe = true
            }
            // calculte checkin button
            deviceDetailViewModel.checkedInView()
                .shadow(color:.black, radius: 3,x: 1, y: 1)
                .scaleEffect(showCheckin ? 1 : 0)
                .animation(.easeInOut)
                .onAppear {
                self.showCheckin = true
            }
        }
        // spacer to make information show at the top - it's just prettier that way
        Spacer()
      }
      .onAppear {
        // on view appear update device to pull all information
        self.deviceDetailViewModel.updateDevice()
        }
    }
}
