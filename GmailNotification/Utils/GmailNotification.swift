import UserNotifications
import SwiftUI

class GmailNotification {
    private static var isAsked = false
    
    static public func requestAuthorization() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("====>request authorization error", error)
            }
        }
    }
    
    static public func pushNotification(title: String, body: String, badge: NSNumber?){
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                if let badge = badge {
                    content.badge = badge
                }
                // could add .userInfo
                print("-----------------> Push")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false);
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger);
                
                notificationCenter.add(request, withCompletionHandler: { error in
                    if let error = error {
                        print("====>push notification error", error)
                    }
                })
            } else {
                if !isAsked {
                    requestAuthorization()
                    isAsked = true
                }
            }
        }
    }
}
