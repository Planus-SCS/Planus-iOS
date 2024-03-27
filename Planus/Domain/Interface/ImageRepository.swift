//
//  ImageRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

protocol ImageRepository {
    func fetch(key: String) -> Single<Data>
}
