//
//  DeviceModel.swift
//  App Crawler
//
//  Created by Andrew Pirkl on 4/20/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

protocol Device {
    static func deviceRequest(baseURL: URLComponents,id: Int,credentials: String, session: URLSession, completion: @escaping (Result<Device,Error>)-> Void)
    
    static func updateRequest(baseURL: URLComponents, checkinInt: Int ,id: Int,credentials: String, session: URLSession, completion: @escaping (Result<Data,Error>)-> Void)
    
    static func wipeRequest(baseURL: URLComponents,id: Int,passcode: Int?, credentials: String, session: URLSession, completion: @escaping (Result<Data,Error>)-> Void)
    
    var id: Int {get }
    var name: String? {get }
    var serialNumber: String? {get }
    var assetTag: String? {get }
    var isCheckedIn: Bool? {get }
    var managed: Bool? {get }
}
