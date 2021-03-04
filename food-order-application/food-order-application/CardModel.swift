//
//  CardModel.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//

import Foundation


class CartModel: NSObject {
    var foodId:Int = 0
    var foodName:String
    var foodQty:Int
    var totalPrice:Float
    
    init(foodId:Int,foodName:String,foodQty:Int,totalPrice:Float) {
        self.foodId=foodId
        self.foodName=foodName
        self.foodQty=foodQty
        self.totalPrice=totalPrice
    }
    
}
