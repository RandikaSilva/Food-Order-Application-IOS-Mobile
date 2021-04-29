//
//  LocationService.swift
//  food-order-application
//
//  Created by Lasitha on 2021-04-30.
//

import UIKit
import CoreLocation

class LocationService: NSObject {
    
    let locationManager = CLLocationManager()
    let firestoreDataService = FirebaseService()
    
    func configure(context:CLLocationManagerDelegate,locationManager:CLLocationManager){
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()

        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
               if let error = error {
                   print("Request Authorization Failed (\(error), \(error.localizedDescription))")
               }
           }

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate=context
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func getGpsLocation(completion: @escaping (Any)->()){
        let location = CLLocation()
        let currentLoc = locationManager.location
        location.setValue(currentLoc?.coordinate.latitude ?? 0.0, forKey: "latitude")
        location.setValue(currentLoc?.coordinate.longitude ?? 0.0, forKey: "longitude")
        completion(location)
    }
    
    func calculateDistance(gpsLocation:CLLocation,resturentLocation:CLLocation){
        print("Getting user location")
        let distance=gpsLocation.distance(from: resturentLocation) / 1000
        print(distance)
        if distance<=10{
            print("Customer is close")
            let readyOrders = OrderData.orderList.filter{ $0.value.status == 2 }
            print(OrderData.orderList)
            for order in readyOrders{
                print("We have orders with status 2")
                self.firestoreDataService.changeOrderStatus(orderId: order.key, status: 3){
                    completion in
                    if completion==204{
                        print("Order status updated to arriving")
                    }else{
                        print("Unable to update order status to arriving")
                    }
                }
            }
        }
    }
    
}


