//
//  ContentViewModel.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftUI


class ContentViewModel: ObservableObject{
    private var maxDevices = 100
    
    var credentials: Credentials = Credentials(username: "", password: "", server: URLComponents())
    var searchTasks: [URLSessionDataTask?] = [URLSessionDataTask?]()
    @Published var showSheet = true
    

    private var typing: Int = 0 {
        willSet(newValue) {
            if newValue == 0 {
                searchHandler(searchValue: "*" + lookupText + "*")
            }
        }
    }
    
    @Published var lookupText: String = "" {
        willSet {
            self.typing += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.typing -= 1
            }
        }
    }
    
    @Published private(set) var projectedDeviceArray = Array<SearchedDevice>()
    var wrappedDeviceArray: Array<SearchedDevice> {
        get {
            return projectedDeviceArray
        }
        set(newValue) {
            DispatchQueue.main.async {
                self.projectedDeviceArray = (newValue.count > self.maxDevices) ? Array(newValue.dropLast(newValue.count - self.maxDevices)) : newValue
            }
        }
    }
    
    //this should really be an incrementer and a calculated bool, but it's fine
    @Published var isLoading: Bool = false
    
    enum ActiveSheet {
       case login, scanner, errorView
    }
    var activeSheet: ActiveSheet = .login {
        willSet {
            DispatchQueue.main.async {
                self.showSheet = true
            }
        }
    }
    
    private var errorDescription: String = "Unknown" {
        willSet {
            activeSheet = .errorView
        }
    }
    
    init(credentials: Credentials?) {
        guard let myCredentials = credentials else {
            self.activeSheet = .login
            return
        }
        self.credentials = myCredentials
        self.showSheet = false
        self.lookupText = ""
    }
    
    
    func setIsLoading(_ isLoading: Bool){
        DispatchQueue.main.async {
            self.isLoading = isLoading
        }
    }
    func setErrorDescription(_ description: String){
        DispatchQueue.main.async {
            self.errorDescription = description
        }
    }
    

    func mobileDeviceSearch(searchText:String, completion: @escaping (Result<[SearchedDevice], Error>)-> Void)-> URLSessionDataTask? {
        return MobileDevice.mobileSearchRequest(baseURL: credentials.server, match: searchText, credentials: credentials.basicCreds, session: URLSession.shared) {
            (result) in
            switch result {
            case .success(let deviceList):
                completion(.success(deviceList.mobileDevices))
                
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    
    func computerSearch(searchText: String, completion: @escaping (Result<[SearchedDevice], Error>)-> Void)-> URLSessionDataTask? {
        return Computer.computerSearchRequest(baseURL: credentials.server, match: searchText, credentials: credentials.basicCreds, session: URLSession.shared) {
            (result) in
            switch result {
            case .success(let computerList):
                completion(.success(computerList.computers))
                
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    
    private func searchHandler(searchValue: String) {
        setIsLoading(true)
        for task in searchTasks {
            task?.cancel()
        }
        DispatchQueue.global().async{
            let group = DispatchGroup()
            var deviceList = Array<SearchedDevice>()
            var allowMobile = false
            var allowComputer = false
            var lastError: Error?
            group.enter()
            self.searchTasks.append(self.computerSearch(searchText: searchValue) {
                result in
                switch result {
                case .success(let computerList):
                    deviceList.append(contentsOf: computerList)
                    allowMobile = true
                case .failure(let error):
                    lastError = error
                    print(error)
                }
                group.leave()
            })
            
            group.enter()
            self.searchTasks.append(self.mobileDeviceSearch(searchText: searchValue) {
                result in
                switch result {
                case .success(let mobileDeviceList):
                    deviceList.append(contentsOf: mobileDeviceList)
                    allowComputer = true
                case .failure(let error):
                    lastError = error
                    print(error)
                }
                group.leave()
            })
            
            group.wait()
            self.setIsLoading(false)
            if !allowMobile && !allowComputer {
                if let lastError = lastError as? URLError {
                    if lastError.errorCode == -999
                    {
                        return
                    }
                }
                DispatchQueue.main.async {
                    print(lastError as Any)
                    self.errorDescription = lastError?.localizedDescription ?? "Unknown"
                }
                print("cancelled")
                return
            }
            self.wrappedDeviceArray = deviceList
        }
    }

    func checkCameraAccess(completion: @escaping (Bool)->Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: 
                completion(true)
            default:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
        }
    }
    
    func currentModal() -> AnyView {
        switch activeSheet {
        case .login:
            return AnyView(LoginView() {
                (credentials,devices) in
                self.credentials = credentials
                self.wrappedDeviceArray = devices
            })
        
        case .scanner:
            #if !targetEnvironment(macCatalyst)
            return AnyView(CodeScannerView(codeTypes: [.qr,.aztec,.code128,.code39,.code39Mod43,.code93,.dataMatrix,.ean13,.ean8,.interleaved2of5,.itf14,.pdf417,.upce], simulatedData: "testdata") {
                result in
                self.showSheet = false
                switch result {
                case .success(let code):
                    self.lookupText = code
                case .failure(let error):
                    self.errorDescription = error.localizedDescription
                    print(error.localizedDescription)
                }
            })
            #else
            return AnyView(ImagePicker(){
                image in
                print(image)
            })
            #endif
        case .errorView:
            return AnyView(InfoSheetView(title: "An error occurred", description: self.errorDescription, image: Image(systemName: "exclamationmark.octagon.fill")))
        }
    }
}
