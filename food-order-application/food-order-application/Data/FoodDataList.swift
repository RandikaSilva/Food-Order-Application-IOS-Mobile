//
//  FoodDataList.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-04.
//

import Foundation

var firebaseFoodData=FirebaseService()

struct ItemData {
    static var itemList:[Item] = []
}


func populateFoodList(items:[Item]){
    ItemData.itemList=items
    print("Items populated")
}
