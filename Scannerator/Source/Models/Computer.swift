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
    var remoteManagement: RemoteManagement?
}

struct RemoteManagement: Codable {
    var managed: Bool?
}

struct ComputerSearch: Codable {
    var computers: [SearchedDevice]
}

extension Computer: Device {
    
    var id: Int { return self.general.id }
    
    var name: String? { return self.general.name }
    
    var serialNumber: String? { return self.general.serialNumber }
    
    var assetTag: String? { return self.general.assetTag }
    
    var managed: Bool? { return self.general.remoteManagement?.managed }
    
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
    
    // currently hidden - Jamf School doesn't have parity for this(api is broken) and it can be too powerful
    static func wipeRequest(baseURL: URLComponents,id: Int,passcode: Int?, credentials: String, session: URLSession, completion: @escaping (Result<Data,Error>)-> Void){
        var urlComponents = baseURL
        guard let passcode = passcode else {
            completion(.failure(NSError()))
            return
        }
        urlComponents.path="/JSSResource/computercommands/command/EraseDevice/passcode/\(passcode)/id/\(id)"
        
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
    
    static func updateRequest(baseURL: URLComponents, checkinInt: Int ,id: Int,credentials: String, session: URLSession, completion: @escaping (Result<Data,Error>)-> Void) {
        let xmlString = "<computer><extension_attributes><extension_attribute><name>isCheckedIn</name><value>\(checkinInt)</value></extension_attribute></extension_attributes></computer>"
        let xmlData = xmlString.data(using: .utf8)
        
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/computers/id/\(id)"
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.put,dataToSubmit: xmlData, contentType: .xml ,accept: ContentType.xml)
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

