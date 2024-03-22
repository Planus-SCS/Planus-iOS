//
//  Vibrate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/25.
//

import UIKit
import AVFoundation

enum Vibration: String, CaseIterable {
    
    static var allCases: [Vibration] {
        let defaultList = [
            error,
            success,
            warning,
            light,
            medium,
            heavy,
            selection,
            oldSchool,
        ]
        
        return defaultList
    }
    
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case selection
    /// 옛 진동 방식
    case oldSchool
    
    public func vibrate() {
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
