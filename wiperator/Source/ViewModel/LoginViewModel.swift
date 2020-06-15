//
//  LoginViewModel.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/31/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var networkID: String = ""
    @Published var apiKey: String = ""
    @Published var enteredURL: String = "" {
        willSet(newValue){
            baseURL = URLBuilder.BuildURL(baseURL: newValue)
        }
    }
    var baseURL: URLComponents = URLComponents()
    @Published var serverError = ""
    @Published var loggingIn = false
    
    var credentials: Credentials {
        get {
            return Credentials(username: networkID, password: apiKey, server: baseURL)
        }
    }
    
    @Published var saveCredentials = true

    func loadCredentials() {
        enteredURL = UserDefaults.standard.string(forKey: "jamfSchoolServer") ?? enteredURL
        do {
            let credentials = try Credentials.loadCredentials(server: enteredURL)
            networkID = credentials.networkID
            apiKey = credentials.apiKey
        }
        catch {
            print("Error loading credentials: \(error)")
        }
    }
    
    func syncronizeCredentials() throws{
        if saveCredentials {
            UserDefaults.standard.set(enteredURL, forKey: "jamfSchoolServer")
            do {
                try Credentials.saveCredentials(networkID: networkID, apiKey: apiKey, server: enteredURL)
                }
            catch {
                print("failed to save credentials with error: \(error)")
            }
        }
        else {
            do {
                try Credentials.removeCredentials(server: enteredURL, networkID: networkID)
            }
        }
    }
    
    public func deviceSearch(completion: @escaping (Result<[Device], Error>) -> Void)-> URLSessionDataTask?{
        return Device.allDevicesRequest(baseURL: baseURL, credentials: credentials.basicCreds, session: URLSession.shared) {
            (result) in
            switch result {
            case .success(let allDevices):
                completion(.success(allDevices.devices))
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    func mobileDeviceSearch(completion: @escaping (Result<[MobileDevice], Error>)-> Void)-> URLSessionTask? {
            return MobileDevice.mobileSearchRequest(baseURL: baseURL, match: "*", credentials: credentials.basicCreds, session: URLSession.shared) {
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
    
    func computerSearch(completion: @escaping (Result<[Computer], Error>)-> Void)-> URLSessionTask? {
        return Computer.computerSearchRequest(baseURL: baseURL, match: "*", credentials: credentials.basicCreds, session: URLSession.shared) {
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
    
    public func login(completion: @escaping (Credentials,[SearchedDevice])->Void) {
        loggingIn = true
        DispatchQueue.global().async{
            let group = DispatchGroup()
            var deviceList = Array<SearchedDevice>()
            var allowMobile = false
            var allowComputer = false
            var lastError: Error?
            group.enter()
            self.computerSearch() {
                [weak self]
                result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let computerList):
                    deviceList.append(contentsOf: computerList)
                    allowMobile = true
                case .failure(let error):
                    lastError = error
                    print(error)
                }
                group.leave()
            }
            
            group.enter()
            self.mobileDeviceSearch() {
                [weak self]
                result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let mobileDeviceList):
                    deviceList.append(contentsOf: mobileDeviceList)
                    allowMobile = true
                case .failure(let error):
                    lastError = error
                    print(error)
                }
                group.leave()
            }
            group.wait()
            
            if !allowMobile && !allowComputer {
                DispatchQueue.main.async {
                    if let myError = lastError {
                        self.serverError = "Failed to log in\n \(myError.localizedDescription)"
                    }
                    self.loggingIn = false
                    return
                }
            }
            
            completion(self.credentials,deviceList)
            
            
        }
        
        
//        deviceSearch() {
//            [weak self]
//            result in
//            guard let self = self else {
//                return
//            }
//            switch result {
//            case .success(let devices):
//                completion(self.credentials,devices)
//                DispatchQueue.main.async {
////                    self.presentationMode.wrappedValue.dismiss()
//                    self.loggingIn = false
//                    self.serverError = "itworked?"
//                }
//                do {
//                    try self.syncronizeCredentials()
//                }
//                catch {
//                    print("Failed to save credentials with error: \(error)")
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.serverError = "Failed to log in\n \(error.localizedDescription)"
//                    print(error)
//                    self.loggingIn = false
//                }
//            }
//        }
    }
    
    
    public func readConfig() -> Bool{
        if let managedConf = UserDefaults.standard.object(forKey: "com.apple.configuration.managed") as? [String:Any?] {
            guard let myServerURL = managedConf["serverURL"] as? String else {
                return false
            }
            self.enteredURL = myServerURL
            guard let myNetworkID = managedConf["networkID"] as? String else {
                return false
            }
            self.networkID = myNetworkID
            guard let myApiKey = managedConf["apiKey"] as? String else {
                return false
            }
            self.apiKey = myApiKey
            return true
            
        }
        guard let myServerURL = Bundle.main.object(forInfoDictionaryKey: "serverURL") as? String else {
            return false
        }
        self.enteredURL = myServerURL
        guard let myNetworkID = Bundle.main.object(forInfoDictionaryKey: "networkID") as? String else {
            return false
        }
        self.networkID = myNetworkID
        guard let myApiKey = Bundle.main.object(forInfoDictionaryKey: "apiKey") as? String else {
            return false
        }
        self.apiKey = myApiKey
        return true
    }
}
