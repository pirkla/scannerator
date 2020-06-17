//
//  DeviceDetailView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/7/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//
// ugh todo: cleanup and split up responsibilities
import SwiftUI

struct DeviceDetailView: View {
//    @State var scale: CGFloat = 1
    @State private var showCheckin = false
    @State private var showWipe = false
    @ObservedObject var deviceDetailViewModel: DeviceDetailViewModel
    var isLoading: Binding<Bool>
    
    @State var animate: Bool = false {
        willSet {
            print("changed")
        }
    }
    
    static let rotationCount = 13

    var body: some View {
      VStack {
        VStack {
            Text(deviceDetailViewModel.searchedDevice.name ?? "")
            Text(deviceDetailViewModel.searchedDevice.serialNumber ?? "")
            Text(deviceDetailViewModel.searchedDevice.assetTag ?? "")
        }
        HStack {
            deviceDetailViewModel.wipeView($deviceDetailViewModel.showModal)
                .scaleEffect(showWipe ? 1 : 0)
                .animation(.easeInOut)
                .onAppear {
                self.showWipe = true
            }
                .onDisappear {
                    self.showWipe = false
            }
            deviceDetailViewModel.checkedInView()
                .scaleEffect(showCheckin ? 1 : 0)
                .animation(.easeInOut)
                .onAppear {
                self.showCheckin = true
            }
                .onDisappear {
                self.showCheckin = false
            }
        }
        LogoView(animate: $deviceDetailViewModel.isLoading).frame(width: 100, height: 100)
        Spacer()
      }
      .onAppear {
        self.deviceDetailViewModel.updateDevice()
        }
    }
    
//    var symbols: some View {
//        ForEach(0..<LogoView.rotationCount) { i in
//                Parallelogramb(
//                    spinTime: self.deviceDetailViewModel.doneLoading ? 1:0,
//                    animationTime:self.deviceDetailViewModel.doneLoading ? 01:0
//                )
//                    .opacity(0.5)
//                    .rotationEffect(.degrees(Double(i) / Double(LogoView.rotationCount)) * 360.0,anchor: .bottomLeading)
//            .frame(width:100)
//        }
//        .animation(self.deviceDetailViewModel.doneLoading ? Animation.linear(duration: 5.0) : Animation.linear(duration: 5.0).repeatForever(autoreverses: false))
////        .onAppear {
////            self.animate = true
////        }
////        .onAppear {
////            withAnimation(!self.animate ? Animation.linear(duration: 5.0) : Animation.linear(duration: 5.0).repeatForever(autoreverses: false)) {
////            self.animate = true
////            }
////        }
//    }
//
//    var spinBody: some View {
//        GeometryReader { geometry in
//            self.symbols
//                .scaleEffect(1.0 / 4.0, anchor: .top)
//                .position(x: geometry.size.width / 1.925, y: (3.0 / 4.0) * geometry.size.height)
//        }
//    }
//
    
}

struct DeviceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetailView(deviceDetailViewModel: DeviceDetailViewModel(searchedDevice: SearchedDevice(id: 1), deviceType: Computer.self, credentials: Credentials()))
    }
}

