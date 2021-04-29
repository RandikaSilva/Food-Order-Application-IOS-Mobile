//
//  OrderData.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//



import Foundation

struct OrderData {
    static var orderList:[String:OrderModel] = [String: OrderModel]()
}

func populateOrderList(orders:[OrderModel]){
    var orderList:[String:OrderModel]=[String: OrderModel]()
    for order in orders{
        orderList[order.orderId]=order
    }
    OrderData.orderList=orderList
}

func generateOrderId()->String{
    let uuid = NSUUID().uuidString
    return uuid
}
