//
//  URLBuilder.swift
//  LocationShmocation
//
//  Created by Andrew Pirkl on 5/19/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

class URLBuilder {
    
    /**
     Create a url from someone's messed up string
     
     - returns:
     A concatenated url
     
     - parameters:
        - baseURL: The base url of the instance. Ex: manage.zuludesk.com
     */
    static func BuildURL(baseURL: String) -> URLComponents
    {
        let myURL = baseURL.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")
        var components = URLComponents()
        components.scheme = "https"
        components.host = myURL
        return components
    }
    
    /**
     Create a url from elements for use with Jamf Pro
     
     - returns:
     A concatenated url
     
     - parameters:
        - baseURL: The base url of the instance. Ex: url.jamfcloud.com
     */
    static func BuildJamfURL(baseURL: String) -> URL?
    {
        var myURL = baseURL.replacingOccurrences(of: "https:", with: "").replacingOccurrences(of: "http:", with: "").replacingOccurrences(of: "/", with: "")
        var port: Int?
        if let range = myURL.range(of: ":") {
            let portString = String(myURL[range.upperBound...])
            myURL.removeSubrange(range.lowerBound..<myURL.endIndex)
            port = Int(portString)
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = myURL
        components.port = port

        return components.url
    }
}
