//
//  NetworkError.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case httpRequestError
    case httpResponseError
    case unKnownError(String)
    case unMatchingCodableTypeError
    case invalidURLFormatError
    case httpBodyEncodingError
    case nilDataError
}

enum TokenError: Error, Equatable {
    case tokenExpired
}
