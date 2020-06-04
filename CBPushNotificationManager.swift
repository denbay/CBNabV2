//
//  CBPurchaseManager.swift
//  Alamofire
//
//  Created by Dzianis Baidan on 04/06/2020.
//

import UIKit
import Foundation

public class CBPushNotificationManager: NSObject {
    
    // - Shared
    static let shared = CBPushNotificationManager()
    
    // - Manager
    private let notificationCenter = UNUserNotificationCenter.current()
        
    func register(application: UIApplication) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        notificationCenter.requestAuthorization(options: options) { [weak self] (_, _) in
            DispatchQueue.main.async { [weak self] in
                self?.resetAllPushNotifications()
                self?.scheduleNaebNotifications()
            }
        }
    }
    
    private func resetAllPushNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
}

// MARK: -
// MARK: - Create local notifications

extension CBPushNotificationManager {
    
    func scheduleNaebNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        
        createNotification(
            title: "Приветственный бонус",
            message: "+300 процентов на 1й депозит!",
            timeInterval: 60 * 60)
        
        createNotification(
            title: "Вся Россия уже играет.",
            message: "Доступно для вас",
            timeInterval: 60 * 60 * 2)
        
        createNotification(
            title: "98%",
            message: "Процент отдачи слотов до 98%!",
            timeInterval: 60 * 60 * 12)
        
        createNotification(
            title: "Счастливчик постоянно выигрывает",
            message: "В приложении крупные суммы денег!",
            timeInterval: 60 * 60 * 24)
        
        createNotification(
            title: "Миллион за неделю!",
            message: "Миллион за неделю!!!",
            timeInterval: 60 * 60 * 36)
                
        var lastNotificationTimeInterval: Double = 60 * 60 * 48
        for _ in 0...30 {
            createNotification(
                title: "Ежеднеынй джекпот! Игрок Банжи007 выиграл 70 000 руб",
                message: "И получил выплату на кошелек. Хочешь также? Играй и побеждай",
                timeInterval: lastNotificationTimeInterval)
            lastNotificationTimeInterval += 60 * 60 * 24
        }
    }
    
    private func createNotification(title: String, message: String, timeInterval: Double) {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "\(timeInterval)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in }
    }
    
}
