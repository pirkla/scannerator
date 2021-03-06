//
//  JPDevice.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/14/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct Computer: Codable, Identifiable {
    var id : Int
    var name: String?
    var udid: String?
    var serialNumber: String?
    var macAddress: String?
    var altMacAddress: String?
    var assetTag: String?
    var barCode1: String?
    var barCode2: String?
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

struct JPDeviceSearch: Codable {
    var computers: [Computer]?
}

extension Computer {
    //todo: this could be made into a more general datatask extension instead
    static func deviceSearchRequest(request: URLRequest, session: URLSession, completion: @escaping (Result<AllDevices,Error>)-> Void)-> URLSessionDataTask? {
        let dataTask = session.dataTask(request: request) {
            (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseObject = try decoder.decode(AllDevices.self, from: data)
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
    
    static func deviceSearchRequest(baseURL: URLComponents,match: String,credentials: String, session: URLSession, completion: @escaping (Result<AllDevices,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/JSSResource/computers/match/"+match
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        let dataTask = deviceSearchRequest(request: myRequest, session: session){
            (result) in
            completion(result)
        }
        return dataTask
    }
}

