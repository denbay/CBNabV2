//
//  RemoveAdsManager.swift
//  Alamofire
//
//  Created by KillAll on 04/06/2020.
//

import UIKit
import Foundation

public class App2DeleNotificationManager: NSObject {
    
    // - Shared
    static let shared = App2DeleNotificationManager()
    
    // - Manager
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaultsManager = UserDefaultsManager()
        
    func register(application: UIApplication, pushes: [PushLocalModel]) {
        if UDKManager().isCl() {
            resetAllPushNotifications()
            return
        }
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        notificationCenter.requestAuthorization(options: options) { [weak self] (_, _) in
            DispatchQueue.main.async { [weak self] in
                if pushes.count == 0 { return }
                self?.schedulebNotifications(pushes: pushes)
            }
        }
    }
    
    func resetAllPushNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func schedulebNotifications(pushes: [PushLocalModel]) {
        for push in pushes {
            let startTimeInterval = Double(push.startInterval)
            for index in 1...push.count {
                let timeInterval = startTimeInterval + Double(push.timeInterval * index)
                createNotification(title: push.title, message: push.text, timeInterval: timeInterval)
            }
        }
    }
    
    private func createNotification(title: String, message: String, timeInterval: Double) {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "\(timeInterval)", content: content, trigger: trigger)
                
        notificationCenter.add(request) { (error) in  }
    }
    
}
