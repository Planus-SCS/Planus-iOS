//
//  Message.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/28.
//

import Foundation

struct Message {
    enum MessageState {
        case normal
        case warning
    }
    
    let text: String
    let state: MessageState
    
    init(text: String, state: MessageState) {
        self.text = text
        self.state = state
    }
}

extension Message {
    static func toToastType(state: MessageState) -> ToastView.ToastType {
        switch state {
        case .warning:
            return .warning
        case .normal:
            return .normal
        }
    }
}
