//
//  CardDataList.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//

import Foundation


struct CartData {
    static var cartItemList:[CartModel] = []
}

func addNewItem(item:CartModel){
    CartData.cartItemList.append(item)
}

func removeCart(){
    CartData.cartItemList=[]
}

func generateOrderTotal()->Float{
    var total:Float = 0.0
    for item in CartData.cartItemList{
        total+=item.totalPrice
    }
    return total
}
