//
//  Network.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-08-19.
//

import Foundation

public enum NetworkError: Error {
    case transport(URLError)
    case httpStatus(code: Int)
    case unknown(Error)

    public var allowsRetry: Bool {
        switch self {
        case .transport(let urlError):
            switch urlError.code {
            case .timedOut,
                 .notConnectedToInternet,
                 .networkConnectionLost,
                 .cannotConnectToHost:
                return true
            default:
                return false
            }

        case .httpStatus(let code):
            switch code {
            case 500, 502, 504:
                return true
            case 429:
                return false
            case 503:
                return false
            default:
                return false
            }

        case .unknown:
            return false
        }
    }
    
    public var message: String {
        switch self {
        case .transport(let urlError):
            return "\(urlError.code)"
        case .httpStatus(let code):
            return "\(code)"
        case .unknown:
            return "unknown"
        }
    }
}
