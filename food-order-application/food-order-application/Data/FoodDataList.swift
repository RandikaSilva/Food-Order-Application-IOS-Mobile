//
//  FoodDataList.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-04.
//

import Foundation

struct FoodData {
    static var foodList:[ItemModel] = []
}

func fetchFoodData(){
    FoodData.foodList=[ItemModel(foodId: 1, foodName: "Rice", foodDescription: "This is a spicy Rice", foodPrice: 450.0, foodPhoto: "FoodPhoto1", foodDiscount: 50.0),ItemModel(foodId: 2, foodName: "Rice & Curry", foodDescription: "This is a Rice & Curry", foodPrice: 550.0, foodPhoto: "Food", foodDiscount: 10.0)]
}
