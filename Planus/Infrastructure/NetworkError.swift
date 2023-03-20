//
//  NetworkError.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
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
