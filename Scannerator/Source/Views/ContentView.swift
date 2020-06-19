//
//  ContentView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var contentViewModel = ContentViewModel()
    
    var body: some View {
        VStack() {

            HStack() {
                Spacer()
                Button(action: {
                    self.contentViewModel.activeSheet = .login
                }) {
                    Text("Login")
                }.padding(.leading, 20.0).frame(width: 70, height: 80, alignment: .leading)
                
                LogoView(animate: $contentViewModel.isLoading).frame(width: 80, height: 80)
            }
            
            
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
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    #else
                    TextField("", text:  $contentViewModel.lookupText)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(.leading, 6.0)
                    #endif
                }
                .frame(idealWidth: 250.0,maxWidth: 350)
                .background(Color.init("TextBackground"))
                .cornerRadius(10)
            }
            #if targetEnvironment(macCatalyst)
            NavigationView { DeviceListView(deviceArray: self.contentViewModel.projectedDeviceArray, credentials: self.contentViewModel.credentials, setIsLoading: contentViewModel.setIsLoading(_:), setErrorDescription: contentViewModel.setErrorDescription(_ :))
            }.labelsHidden()
            .navigationBarTitle("")
            .navigationBarHidden(true)
            #else
            NavigationView { DeviceListView(deviceArray: self.contentViewModel.projectedDeviceArray, credentials: self.contentViewModel.credentials, setIsLoading: contentViewModel.setIsLoading(_:), setErrorDescription: contentViewModel.setErrorDescription(_ :))
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
