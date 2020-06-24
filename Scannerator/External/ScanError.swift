//
//  ScanError.swift
//  Scannerator
//
//  Created by Andrew Pirkl on 6/21/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation


public enum ScanError: Error {
    case badInput
    case badOutput
    case cancelled
    case noCamera
}

extension ScanError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badInput:
            return "Scanner input could not be read"
        case .badOutput:
            return "There was an error with the scanner output"
        case .cancelled:
            return "Scanner cancelled"
        case .noCamera:
            return "No camera could be found"
        }
    }
}
