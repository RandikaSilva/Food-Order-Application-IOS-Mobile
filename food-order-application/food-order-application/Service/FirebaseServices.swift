//
//  FirebaseServices.swift
//  food-order-application
//
//  Created by Lasitha on 2021-04-30.
//

import UIKit;
import FirebaseAuth;
import FirebaseFirestore;

import FirebaseDatabase
import CoreLocation

class FirebaseService: NSObject {
    let db = Firestore.firestore()
    
    let notificationService = NotificationService()
    
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
            "status":order.status,
            "timestamp":order.timestamp
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
        print(UserData.mobileNumber)
        print(order.orderId)
        let ref = Database.database().reference().child(UserData.mobileNumber).child(order.orderId)
        ref.setValue(orderData)
    }
    
 
    
    func fetchItemsData(category:String="Other",completion: @escaping (Bool)->()) {
        var itemList:[Item]=[]
        db.collection("items").whereField("category", isEqualTo: category).getDocuments() { (querySnapshot, err) in
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
                    let category=document.data()["category"] as! String
                    itemList.append(Item(itemId: itemId, itemName: itemName, itemThumbnail: itemThumbnail, itemDescription: itemDescription, itemPrice: itemPrice,itemDiscount: itemDiscount,isAvailable: isAvailable,category: category))
                }
                populateFoodList(items: itemList)
                completion(true)
            }
        }
    }
    
    
    func listenToResturentLiveLocation(){
        let ref = Database.database().reference()
        ref.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
//            let latitude =  postDict["RESTURENTLOCATION"]?["LATITUDE"] as! Double
//            let longitude = postDict["RESTURENTLOCATION"]?["LONGITUDE"] as! Double
//            RESTURENTLOCATION.latitude=latitude
//            RESTURENTLOCATION.longitude=longitude
        })
    }
    
    func changeOrderStatus(orderId:String, status:Int, completion: @escaping (Int)->()){
        db.collection("orders").document(orderId).updateData(["status":status]){
            err in
            if let err = err {
                completion(500)
            } else {
                FirebaseService().updateOrderStatus(orderId: orderId, status: status)
                completion(204)
            }
        }
    }
    
    
    func listenToOrderStatus(){
        let ref = Database.database().reference().child(UserData.mobileNumber)
        ref.observe(DataEventType.value, with: { (snapshot) in
            
            if !snapshot.exists() {
                    return
            }
            var data = snapshot.value as! [String: Any]
            for (key,value) in data{
                let statusData = value as! [String:Any]
                var orderStatusData:StatusDataModel=StatusDataModel()
                orderStatusData.orderId=statusData["orderId"] as! String
                orderStatusData.status=statusData["status"] as! Int
                orderStatusData.isRecieved=statusData["isRecieved"] as! Bool
                if orderStatusData.status != 0 && orderStatusData.status != 3{
                    if orderStatusData.isRecieved == false{
                        self.notificationService.pushNotification(orderId: orderStatusData.orderId, orderStatus: orderStatusData.status){
                            result in
                            if result == true{
                                self.markOrderAsRecieved(orderStatusData: orderStatusData,key: key)
                            }
                        }
                    }
                }
            }
        })
    }
    
    func markOrderAsRecieved(orderStatusData:StatusDataModel,key:String){
        orderStatusData.isRecieved=true
        print("Updating order status")
        let ref = Database.database().reference().child(UserData.mobileNumber).child(key).setValue(orderStatusData.asDictionary)
    }
    
    func updateOrderStatus(orderId:String,status:Int){
        let ref = Database.database().reference().child(UserData.mobileNumber).child(orderId)
        ref.updateChildValues(["status":status,"isRecieved":false])
    }
    
}
