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
            Button(action: {
                guard let myUrl = self.deviceDetailViewModel.deviceUrl() else {
                    self.deviceDetailViewModel.setErrorDescription("Could not find url")
                    return
                }
                UIApplication.shared.open(myUrl)
            }) {
                HStack {
                    Text(deviceDetailViewModel.searchedDevice.name ?? "").font(.title)
//                    Image(systemName: "link")
                }.padding(.all, 7.0)
            }
            .frame(alignment: .trailing)
            .background(Color.init("TextBackground"))
            .cornerRadius(10)
            .shadow(color:.black, radius: 3,x: 1, y: 1)
            
            Text(deviceDetailViewModel.searchedDevice.serialNumber ?? "").font(.headline).padding(.top, 5)
            Text(deviceDetailViewModel.device?.assetTag ?? " ")
                .padding(.bottom, 10.0)

            deviceDetailViewModel.managedStatusView()
            deviceDetailViewModel.checkinStatusView().padding(.bottom, 20.0)

        }
        HStack {
            deviceDetailViewModel.wipeView($deviceDetailViewModel.showModal)
                .shadow(color:.black, radius: 3,x: 1, y: 1)
                .scaleEffect(showWipe ? 1 : 0)
                .animation(.easeInOut)
                .onAppear {
                self.showWipe = true
            }
            deviceDetailViewModel.checkedInView()
                .shadow(color:.black, radius: 3,x: 1, y: 1)
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

