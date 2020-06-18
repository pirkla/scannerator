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
    var managed: Bool?
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
    
    var managed: Bool? { return self.general.managed }
    
    var isCheckedIn: Bool? {
        guard let checkedInAtr = (extensionAttributes.first {
            $0.name == "isCheckedIn"
        }) else {
            return nil
        }
        if checkedInAtr.value == "1" {
            return true
        }
        else if checkedInAtr.value == "0" {
            return false
        }
        return nil
    }
    
    //400 means device is not managed
    static func wipeRequest(baseURL: URLComponents,id: Int,passcode: Int? = nil, credentials: String, session: URLSession, completion: @escaping (Result<Data,Error>)-> Void){
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/mobiledevicecommands/command/EraseDevice/id/\(id)"
        
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.post,accept: ContentType.json)
        _ = session.dataTask(request: myRequest) {
            (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
        return
    }
    
    
    static func updateRequest(baseURL: URLComponents, checkinInt: Int ,id: Int,credentials: String, session: URLSession, completion: @escaping (Result<Data,Error>)-> Void) {
        let xmlString = "<mobile_device><extension_attributes><extension_attribute><name>isCheckedIn</name><value>\(checkinInt)</value></extension_attribute></extension_attributes></mobile_device>"
        print(xmlString)
        let xmlData = xmlString.data(using: .utf8)
        
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/mobiledevices/id/\(id)"
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.put,dataToSubmit: xmlData, contentType: .xml ,accept: ContentType.xml)
        session.dataTask(request: myRequest) {
            (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                print("success")
                completion(.success(data))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }.resume()
        return
    }

    
    
    static func deviceRequest(baseURL: URLComponents,id: Int,credentials: String, session: URLSession, completion: @escaping (Result<Device,Error>)-> Void) {
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/mobiledevices/id/\(id)"
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

