//
//  JPDevice.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/14/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct MobileDeviceParent: Codable {
    var mobileDevice: MobileDevice
}

struct MobileDevice: Codable {
    var general: MobileDeviceGeneral
    var extensionAttributes: [ExtensionAttribute]
}

struct MobileDeviceGeneral: Codable, Identifiable {
    var id : Int
    var name: String?
    var udid: String?
    var serialNumber: String?
    var macAddress: String?
    var wifiMacAddress: String?
    var assetTag: String?
}

struct MobileDeviceSearch: Codable {
    var mobileDevices: [SearchedDevice]
}

extension MobileDevice: Device {
    
    var id: Int {
        return self.general.id
    }
    
    var name: String? {
        return self.general.name
    }
    
    var serialNumber: String? {
        return self.general.serialNumber
    }
    
    var assetTag: String? {
        return self.general.assetTag
    }
    
    var isCheckedIn: Bool {
        return true
    }
    
    
    func deviceRequest(baseURL: URLComponents,id: String,credentials: String, session: URLSession, completion: @escaping (Result<Device,Error>)-> Void) {
        var urlComponents = baseURL
        urlComponents.path="/api/devices/\(id)"
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        _ = session.fetchDecodedResponse(request: myRequest) {
            (result: Result<MobileDeviceParent, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data.mobileDevice))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return
    }
}
extension MobileDevice {
    static func mobileSearchRequest(baseURL: URLComponents,match: String,credentials: String, session: URLSession, completion: @escaping (Result<MobileDeviceSearch,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/mobiledevices/match/"+match
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
//        let dataTask = mobileSearchRequest(request: myRequest, session: session){
//            (result) in
//            completion(result)
//        }
        let dataTask = session.fetchDecodedResponse(request: myRequest) {
            (result: Result<MobileDeviceSearch, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return dataTask
    }
}

