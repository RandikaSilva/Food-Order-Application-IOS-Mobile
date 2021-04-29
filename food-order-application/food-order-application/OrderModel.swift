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
    var items:[CartModel]
    var total:Float
    var status:Int
    
    init(orderId:String,userEmailAddress:String,items:[CartModel],total:Float,status:Int) {
        self.orderId=orderId
        self.userEmailAddress=userEmailAddress
        self.items=items
        self.total=total
        self.status=status
    }
    
    override init(){
        self.orderId=""
        self.userEmailAddress=""
        self.items=[]
        self.status=0
        self.total=0.0
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
//struct Status{
//    var new:[String:Any]=StatusData().asDictionary
//    var preperation:[String:Any]=StatusData().asDictionary
//    var ready:[String:Any]=StatusData().asDictionary
//    var arriving:[String:Any]=StatusData().asDictionary
//    var done:[String:Any]=StatusData().asDictionary
//    var cancel:[String:Any]=StatusData().asDictionary
//
//    init(orderId:Int) {
//        if orderId==0{
//            new["isActive"]=true
//        }else if orderId==1{
//            preperation["isActive"]=true
//        }else if orderId==2{
//            ready["isActive"]=true
//        }else if orderId==3{
//            arriving["isActive"]=true
//        }else if orderId==4{
//            done["isActive"]=true
//        }else if orderId==5{
//            cancel["isActive"]=true
//        }
//    }
//
//    var asDictionary : [String:Any] {
//        let mirror = Mirror(reflecting: self)
//        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
//          guard let label = label else { return nil }
//          return (label, value)
//        }).compactMap { $0 })
//        return dict
//      }
//}
//
