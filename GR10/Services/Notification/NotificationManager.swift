//
//  NotificationManager.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager {
  
  static let shared = NotificationManager()
  
  var center: UNUserNotificationCenter {
    return UNUserNotificationCenter.current()
  }
  
  // MARK: - Public methods
  func requestAuthorization() {
    center.requestAuthorization(options: [.sound, .alert]) { (didAllow, error) in
      print("❤️ RequestAuthorization = \(didAllow) \(error?.localizedDescription ?? "")")
    }
  }
  
  func removeAllNotifications() {
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
  }
  
  func removePendingNotifications() {
    center.getPendingNotificationRequests(completionHandler: { requests in
      let identifiers = requests.map { $0.identifier }
      self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
    })
  }
  
  func removeDeliveredNotifications() {
    center.getDeliveredNotifications { notifications in
      let identifiers = notifications.map { $0.request.identifier }
      self.center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
  }
  
  func sendNotification(title: String, message: String) {
    let request = getNotificationRequest(title: title, subtitle: message)
    center.add(request)
  }
  
  // MARK: - Private functions
  func getNotificationRequest(title: String, subtitle: String, sound: UNNotificationSound? = .default, trigger: UNTimeIntervalNotificationTrigger? = nil) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = subtitle
    content.sound = sound
    return UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
  }
}
