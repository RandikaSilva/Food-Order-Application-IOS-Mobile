//
//  FirebaseServiceOrder.swift
//  food-order-application
//
//  Created by Lasitha on 2021-04-30.
//

import UIKit
import FirebaseFirestore

class FirebaseServiceOrder: NSObject {
    let db = Firestore.firestore()
    
    func getAllOrders(completion: @escaping (Any)->()){
        print(UserData.emailAddress)
        db.collection("orders").whereField("userEmailAddress", isEqualTo: UserData.emailAddress).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            var orders:[OrderModel] = []
            for document in querySnapshot!.documents {
                let orderId:String=document.data()["orderId"] as! String
                let userEmailAddress:String=document.data()["userEmailAddress"] as! String
                var items:[CartModel]=[]
                let total:Float=document.data()["total"] as! Float
                let status:Int=document.data()["status"] as! Int
                let timestamp:Timestamp=document.data()["timestamp"] as! Timestamp
                let userId:String=document.data()["userId"] as! String
                let order = OrderModel(orderId: orderId, userEmailAddress: userEmailAddress, items: items, total: total, status: status,userId: userId, timestamp: timestamp.dateValue())
                orders.append(order)
            }
            populateOrderList(orders: orders)
            completion(orders)
        }
    }
}
