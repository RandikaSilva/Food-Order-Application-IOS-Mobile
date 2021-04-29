//
//  AppDelegate.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-03.
//

import UIKit;
import Firebase;
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        NotificationService().configure(context: self, application: application)
        LocationService().configure(context: self , locationManager: self.locationManager)
        
        FirebaseService().listenToResturentLiveLocation()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}


extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .denied: // Setting option: Never
                print("LocationManager didChangeAuthorization denied")
            case .notDetermined: // Setting option: Ask Next Time
                print("LocationManager didChangeAuthorization notDetermined")
            case .authorizedWhenInUse: // Setting option: While Using the App
                print("LocationManager didChangeAuthorization authorizedWhenInUse")
                self.locationManager.requestLocation()
            case .authorizedAlways: // Setting option: Always
                print("LocationManager didChangeAuthorization authorizedAlways")
                self.locationManager.requestLocation()
            case .restricted: // Restricted by parental control
                print("LocationManager didChangeAuthorization restricted")
            default:
                print("LocationManager didChangeAuthorization")
        }
  }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let gpsLatitude = manager.location?.coordinate.latitude ?? 0.0
        let gpsLongitude = manager.location?.coordinate.longitude ?? 0.0
        let gpsLocation = CLLocation(latitude: gpsLatitude, longitude: gpsLongitude)
        let resturentLocation = CLLocation(latitude: RESTURENTLOCATION.latitude, longitude: RESTURENTLOCATION.longitude)
        LocationService().calculateDistance(gpsLocation: gpsLocation, resturentLocation: resturentLocation)
    }
  
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager didFailWithError \(error.localizedDescription)")
        if let error = error as? CLError, error.code == .denied {
            self.locationManager.stopMonitoringSignificantLocationChanges()
           return
        }
    }
}
