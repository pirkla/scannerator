//
//  ContentView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var loadingAnimModel = LoadingAnimModel()
    @ObservedObject var contentViewModel = ContentViewModel()
    @State var isLoading = true
    
    var body: some View {
        VStack() {
            LogoView(animate: $loadingAnimModel.isLoading ).frame(width: 100, height: 100)

            HStack() {
                Button(action: {
                    self.contentViewModel.activeSheet = .login
                }) {
                    Text("Login")
                }
            }
            .padding(.bottom, 20.0)
            
            
            HStack() {
                Text("Search")
                    .frame(width: 60.0)
                HStack {
                    #if !targetEnvironment(macCatalyst)
                    Button(action: {
                        self.contentViewModel.checkCameraAccess() {
                            (result) in
                            switch result{
                            case true:
                                self.contentViewModel.activeSheet = .scanner

                            case false:
                                print("camera access denied")
                            }
                        }
                    }) {
                        Image(systemName: "camera.fill")
                            .padding(.leading, 7.0)
                            .frame(width: 30, height:30)
                    }
                    TextField("", text:  $contentViewModel.lookupText)
                    #else
                    TextField("", text:  $contentViewModel.lookupText)
                    .padding(.leading, 6.0)
                    #endif
                }
                .frame(idealWidth: 250.0,maxWidth: 350)
                .background(Color.init("TextBackground"))
                .cornerRadius(10)
            }
            #if targetEnvironment(macCatalyst)
            NavigationView { DeviceListView(deviceArray: self.contentViewModel.deviceArray, credentials: self.contentViewModel.credentials)
            }.labelsHidden()
            #else
            NavigationView { DeviceListView(deviceArray: self.contentViewModel.deviceArray, credentials: self.contentViewModel.credentials)
            }.navigationViewStyle(StackNavigationViewStyle())
            .labelsHidden()
            #endif
        }
        .sheet(isPresented: self.$contentViewModel.showSheet) {
            self.contentViewModel.currentModal()
        }
        .frame(minWidth: 200, idealWidth: 400, maxWidth: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
