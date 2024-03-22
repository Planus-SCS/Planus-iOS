//
//  NetworkMonitor.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/24.
//

import Foundation
import Network
import UIKit

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    private var alertVCs: [CustomAlertViewController?] = []
    
    // 연결타입
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    // monotior 초기화
    private init() {
        monitor = NWPathMonitor()
    }

    // Network Monitoring 시작
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.getConnectionType(path)

            if self?.isConnected == true {
                self?.hideNetworkVCOnRoot()
            } else {
                self?.showNetworkVCOnRoot()
            }
        }
    }

    // Network Monitoring 종료
    public func stopMonitoring() {
        monitor.cancel()
    }

    // Network 연결 타입
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    func showNetworkVCOnRoot() {
        DispatchQueue.main.async { [weak self] in
            let vc = UIApplication.shared.windows.first?.rootViewController?.showErrorPopUp(
                title: "❌ 연결 유실 ❌",
                message: "네트워크 상태를 확인해 주세요 🥹",
                alertAttr: CustomAlertAttr(
                    title: "네트워크 설정하기",
                    actionHandler: {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    },
                    type: .normal)
            )
            
            self?.alertVCs.append(vc)
        }
    }
    
    func hideNetworkVCOnRoot() {
        DispatchQueue.main.async { [weak self] in
            self?.alertVCs.forEach {
                $0?.dismiss(animated: true)
            }
            self?.alertVCs.removeAll()
        }
    }
}

