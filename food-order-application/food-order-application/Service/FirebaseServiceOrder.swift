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
        db.collection("orders").whereField("userEmailAddress", isEqualTo: UserData.emailAddress).addSnapshotListener { querySnapshot, error in
            var orders:[OrderModel] = []
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            for document in querySnapshot!.documents {
                let orderId:String=document.data()["orderId"] as! String
                let userEmailAddress:String=document.data()["userEmailAddress"] as! String
                var items:[CartModel]=[]
                let total:Float=document.data()["total"] as! Float
                let status:Int=document.data()["status"] as! Int
                //let timestamp:Timestamp=document.data()["timestamp"] as! Timestamp
                let order = OrderModel(orderId: orderId, userEmailAddress: userEmailAddress, items: items, total: total, status: status,timestamp: Date())
                orders.append(order)
            }
            populateOrderList(orders: orders)
            completion(orders)
        }
    }
}
