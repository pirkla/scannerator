//
//  JPDevice.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/14/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct ComputerParent: Codable {
    var computer: Computer
}
struct Computer: Codable {
    var general: ComputerGeneral
    var extensionAttributes: [ExtensionAttribute]
}


struct ComputerGeneral: Codable {
    var id : Int
    var name: String?
    var udid: String?
    var serialNumber: String?
    var macAddress: String?
    var altMacAddress: String?
    var assetTag: String?
    var barCode1: String?
    var barCode2: String?
//    var username: String?
//    var realName: String?
//    var email: String?
//    var emailAddress: String?
//    var room: String?
//    var position: String?
//    var building: String?
//    var buildingName: String?
//    var department: String?
//    var departmentName: String?
}

struct ComputerSearch: Codable {
    var computers: [SearchedDevice]
}

extension Computer: Device {
    
    var id: Int { return self.general.id }
    
    var name: String? { return self.general.name }
    
    var serialNumber: String? { return self.general.serialNumber }
    
    var assetTag: String? { return self.general.assetTag }
    
    var isCheckedIn: Bool { return true }
    
    static func deviceRequest(baseURL: URLComponents,id: Int,credentials: String, session: URLSession, completion: @escaping (Result<Device,Error>)-> Void) {
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/computers/id/\(id)"
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        _ = session.fetchDecodedResponse(request: myRequest) {
            (result: Result<ComputerParent, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data.computer))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return
    }
    
}

extension Computer {
    static func computerSearchRequest(baseURL: URLComponents,match: String,credentials: String, session: URLSession, completion: @escaping (Result<ComputerSearch,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/computers/match/"+match
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        let dataTask = session.fetchDecodedResponse(request: myRequest) {
            (result: Result<ComputerSearch, Error>) in
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

