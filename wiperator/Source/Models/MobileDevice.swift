//
//  JPDevice.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/14/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct MobileDevice: Codable, Identifiable {
    var id : Int
    var name: String?
    var udid: String?
    var serialNumber: String?
    var macAddress: String?
    var wifiMacAddress: String?
    var username: String?
    var realName: String?
    var email: String?
    var emailAddress: String?
    var room: String?
    var position: String?
    var building: String?
    var buildingName: String?
    var department: String?
    var departmentName: String?
}

struct MobileDeviceSearch: Codable {
    var mobileDevices: [MobileDevice]
}

extension MobileDevice: SearchedDevice {
    var osValue: OSValue {
        return .mobileDevice
    }
    
    var altMacAddress: String? { return nil }
    var assetTag: String? { return nil }
    var barCode1: String? { return nil }
    var barCode2: String? { return nil }
    
}

extension MobileDevice {
    //todo: this could be made into a more general datatask extension instead
    static func mobileSearchRequest(request: URLRequest, session: URLSession, completion: @escaping (Result<MobileDeviceSearch,Error>)-> Void)-> URLSessionDataTask? {
        let dataTask = session.dataTask(request: request) {
            (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseObject = try decoder.decode(MobileDeviceSearch.self, from: data)
                    completion(.success(responseObject))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        dataTask.resume()
        return dataTask
    }
    
    static func mobileSearchRequest(baseURL: URLComponents,match: String,credentials: String, session: URLSession, completion: @escaping (Result<MobileDeviceSearch,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/mobiledevices/match/"+match
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        let dataTask = mobileSearchRequest(request: myRequest, session: session){
            (result) in
            completion(result)
        }
        return dataTask
    }
}

