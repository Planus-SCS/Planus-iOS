//
//  CreateSocialMonthlyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation

protocol CreateSocialMonthlyCalendarUseCase {
    func execute(date: Date) -> [SocialDayViewModel]
}
