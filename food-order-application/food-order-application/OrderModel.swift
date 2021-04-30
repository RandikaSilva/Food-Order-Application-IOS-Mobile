//
//  OrderModel.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//


import UIKit


import UIKit

class OrderModel: NSObject {
    var orderId:String
    var userEmailAddress:String
    var userId:String
    var items:[CartModel]
    var total:Float
    var status:Int
    var timestamp:Date
    
    init(orderId:String,userEmailAddress:String,items:[CartModel],total:Float,status:Int,userId:String,timestamp:Date=Date()) {
        self.orderId=orderId
        self.userEmailAddress=userEmailAddress
        self.items=items
        self.total=total
        self.status=status
        self.timestamp=timestamp
        self.userId=userId
    }
    
    override init(){
        self.orderId=""
        self.userEmailAddress=""
        self.items=[]
        self.status=0
        self.total=0.0
        self.timestamp=Date()
        self.userId=""
    }
    
    func toAnyObject() -> Any {
        var cartItemList:[Any]=[]
        for item in self.items{
            cartItemList.append([
                "itemId":item.itemId,
                "itemName":item.itemName,
                "itemQty": item.itemQty,
                "itemPrice":item.itemPrice,
                "totalPrice":item.totalPrice,
            ])
        }
        return cartItemList
    }
}

class StatusDataModel: NSObject {
    var orderId:String=""
    var status:Int=0
    var isRecieved:Bool=false
    
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
          guard let label = label else { return nil }
          return (label, value)
        }).compactMap { $0 })
        return dict
      }
}
