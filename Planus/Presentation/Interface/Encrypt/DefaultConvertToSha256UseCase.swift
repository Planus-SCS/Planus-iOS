//
//  DefaultConvertToSha256UseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/08.
//

import Foundation
import CryptoKit

final class DefaultConvertToSha256UseCase: ConvertToSha256UseCase {
    @available(iOS 13, *)
    func execute(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashString
    }
}

protocol ConvertToSha256UseCase {
    func execute(_ input: String) -> String
}
