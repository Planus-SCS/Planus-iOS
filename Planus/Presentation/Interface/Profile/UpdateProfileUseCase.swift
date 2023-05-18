//
//  UpdateProfileUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

protocol UpdateProfileUseCase {
    var didUpdateProfile: PublishSubject<Profile> { get }
    func execute(
        token: Token,
        name: String,
        introduce: String?,
        isImageRemoved: Bool,
        image: ImageFile?
    ) -> Single<Void>
}
