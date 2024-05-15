//
//  NetworkError.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation

public enum NetworkManagerError: Error, Equatable {
    case redirection(Int, String?)
    case clientError(Int, String?)
    case serverError(Int, String?)
    case unKnown(Int, String?)
    case invalidURLFormatError
    case httpBodyEncodingError
    case nilResponseData
    case tokenExpired
}

enum TokenError: Error, Equatable {
    case noneExist
}
