//
//  NetworkManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 15/08/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import Network

class NetworkManager {
    
    static let shared = NetworkManager()
    
    // MARK: -  Public methods
    func runIfNetwork() async {
        let pathMonitor = NWPathMonitor()
        return await withCheckedContinuation { continuation in
            pathMonitor.pathUpdateHandler = {
                guard $0.status == .satisfied else { // No network
                    DispatchQueue.main.async {
                        NotificationManager.shared.sendNotification(title: "error".localized, message: "network".localized)
                    }
                    return pathMonitor.cancel()
                }
                pathMonitor.cancel()
                continuation.resume(returning: ())
            }
            pathMonitor.start(queue: DispatchQueue.global(qos: .background))
        }
    }
}
