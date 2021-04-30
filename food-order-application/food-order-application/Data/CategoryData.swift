//
//  CategoryData.swift
//  food-order-application
//
//  Created by Lasitha on 2021-04-30.
//

import Foundation

struct CategoryData {
    static var categoryList:[CategoryModel] = []
}

func populateCategoryListData(categories:[CategoryModel]){
    CategoryData.categoryList=categories
}
