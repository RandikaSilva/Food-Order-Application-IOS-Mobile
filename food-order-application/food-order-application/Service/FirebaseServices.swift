//
//  FirebaseServices.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//

import UIKit;
import FirebaseAuth;
import FirebaseFirestore;

import FirebaseDatabase

class FirebaseService: NSObject {
    let db = Firestore.firestore()
    
    func registerUser(emailAddress:String,mobileNumber:String,password:String,result: @escaping (_ authResult: Int?)->Void){
        Auth.auth().createUser(withEmail: emailAddress, password: password) { (response, error) in
            if error != nil {
                if let errCode = FirebaseAuth.AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                        case .emailAlreadyInUse:
                            result(2)
                        default:
                            result(0)
                    }
                }
            }else {
                result(1)
            }
        }
    }
    func loginUser(emailAddress:String,password:String,result: @escaping (_ authResult: Int?)->Void){
        Auth.auth().signIn(withEmail: emailAddress, password: password) { (response, error) in
            if error != nil {
                if let errCode = FirebaseAuth.AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                        case .invalidCredential:
                            result(3)
                        case .emailAlreadyInUse:
                            result(2)
                        default:
                            result(0)
                    }
                }
            }else {
                result(1)
            }
        }
    }
    
    
    
    func forgetPassword(emailAddress:String,result: @escaping (_ authResult: Int?)->Void){
        Auth.auth().sendPasswordReset(withEmail: emailAddress) { (error) in
            if error != nil {
                if let errCode = FirebaseAuth.AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                        case .invalidEmail:
                                result(2)
                        default:
                            result(0)
                    }
                }
            }else {
                result(1)
            }
        }
    }
    func addUserToFirestore(user:UserModel){
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "emailAddress": user.emailAddress,
            "mobileNumber": user.mobileNumber,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    func fetchUsersData(completion: @escaping (Bool)->()){
        db.collection("users").getDocuments() { (querySnapshot, err) in
            var isFound=false
            if let err = err {
                completion(false)
            } else {
                for document in querySnapshot!.documents {
                    if(document.data()["emailAddress"] as! String==UserData.emailAddress){
                        let emailAddress:String=document.data()["emailAddress"] as! String
                        let mobileNumber:String=document.data()["mobileNumber"] as! String
                        setUserData(user:UserModel(emailAddress: emailAddress, mobileNumber: mobileNumber))
                        isFound=true
                        break
                    }else{
                        isFound=false
                    }
                }
                if(isFound){
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
    }
    
    func addNewOrder(order:OrderModel,completion: @escaping (Int)->()){
        db.collection("orders").document(order.orderId).setData([
            "orderId":order.orderId,
            "userEmailAddress":order.userEmailAddress,
            "items":order.toAnyObject(),
            "total":order.total,
            "status":order.status
        ]){ err in
            if err != nil{
                completion(500)
            } else {
                FirebaseService().addNewOrderStatus(order: order)
                completion(201)
            }
        }
    }
    
    func addNewOrderStatus(order:OrderModel){
        var statusData:StatusDataModel=StatusDataModel()
        statusData.status=order.status
        statusData.isRecieved=false
        statusData.orderId=order.orderId
        var orderData = statusData.asDictionary
        let ref = Database.database().reference().child(UserData.mobileNumber).child(order.orderId)
        ref.setValue(orderData)
    }
    
    func fetchItemsData(categoryId:Int=0,completion: @escaping (Bool)->()) {
        var itemList:[Item]=[]
        db.collection("items").whereField("categoryId", isEqualTo: categoryId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false)
            } else {
                for document in querySnapshot!.documents {
                    let itemId=document.data()["itemId"] as! String
                    let itemName=document.data()["itemName"] as! String
                    let itemDescription=document.data()["itemDescription"] as! String
                    let itemThumbnail=document.data()["itemThumbnail"] as! String
                    let itemPrice=document.data()["itemPrice"] as! Float
                    let itemDiscount=document.data()["itemDiscount"] as! Float
                    let isAvailable=document.data()["isAvailable"] as! Bool
                    itemList.append(Item(itemId: itemId, itemName: itemName, itemThumbnail: itemThumbnail, itemDescription: itemDescription, itemPrice: itemPrice,itemDiscount: itemDiscount,isAvailable: isAvailable))
                }
                populateFoodList(items: itemList)
                completion(true)
            }
        }
    }
    
    func getAllOrders(completion: @escaping (Any)->()){
        var orders:[OrderModel] = []
        print(UserData.emailAddress)
        db.collection("orders").whereField("userEmailAddress", isEqualTo: UserData.emailAddress).addSnapshotListener { querySnapshot, error in
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
                orders.append(OrderModel(orderId: orderId, userEmailAddress: userEmailAddress, items: items, total: total, status: status))
            }
            populateOrderList(orders: orders)
            completion(orders)
        }
    }
    
}
