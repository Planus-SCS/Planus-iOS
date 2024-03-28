//
//  NetworkError.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation

public enum NetworkManagerError: Error, Equatable {
    case httpRequestError
    case httpResponseError
    case redirection(Int, String?)
    case clientError(Int, String?)
    case serverError(Int, String?)
    case unMatchingCodableTypeError
    case invalidURLFormatError
    case httpBodyEncodingError
    case nilDataError
    case tokenExpired
    case unKnownError(Int, String?)
}

enum TokenError: Error, Equatable {
    case noTokenExist
}
