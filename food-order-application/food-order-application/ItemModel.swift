//
//  ItemModel.swift
//  food-order-application
//
//  Created by Lasitha on 2021-04-30.
//

import UIKit

class Item: NSObject {
    var itemId:String
    var itemName:String
    var itemThumbnail:String
    var itemDescription:String
    var itemPrice:Float
    var itemDiscount:Float
    var isAvailable:Bool
    var category:String

    init(itemId:String,itemName:String,itemThumbnail:String,itemDescription:String,itemPrice:Float,itemDiscount:Float=0.0,isAvailable:Bool=true,category:String="Other") {
        self.itemId=itemId
        self.itemName=itemName
        self.itemThumbnail=itemThumbnail
        self.itemDescription=itemDescription
        self.itemPrice=itemPrice
        self.itemDiscount=itemDiscount
        self.isAvailable=isAvailable
        self.category=category
    }
    
    override init(){
        self.itemId=""
        self.itemName=""
        self.itemThumbnail=""
        self.itemDescription=""
        self.itemPrice=0.0
        self.itemDiscount=0.0
        self.isAvailable=false
        self.category="Other"
    }
}
