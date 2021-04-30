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
    
    func registerUser(user:UserModel,result: @escaping (_ authResult: Int?)->Void){
        if (user.emailAddress != "" && user.mobileNumber != "" && user.password != ""){
            Auth.auth().createUser(withEmail: user.emailAddress, password: user.password) { (response, error) in
                if error != nil {
                    if let errCode = FirebaseAuth.AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                            case .emailAlreadyInUse:
                                result(409)
                            default:
                                result(500)
                        }
                    }else{
                        result(500)
                    }
                }else {
                    self.addUserToFirestore(user: user){
                        completion in
                        if completion{
                            user.uuid=(response?.user.uid)!
                            
                            UserDefaults.standard.set(true, forKey: "isLogged")
                            UserDefaults.standard.set(user.emailAddress, forKey: "emailAddress")
                            UserDefaults.standard.set(user.mobileNumber, forKey: "mobileNumber")
                            UserDefaults.standard.set(response?.user.uid, forKey: "uuid")
                            
                            UserData.emailAddress=user.emailAddress
                            UserData.mobileNumber=user.mobileNumber
                            UserData.uuid=(response?.user.uid)!
                            
                            result(201)
                        }else{
                            result(500)
                        }
                    }
                }
            }
        }else{
            result(400)
        }
    }
    
    func addUserToFirestore(user:UserModel,completion: @escaping (Bool)->()){
        db.collection("users").document(user.emailAddress).setData([
            "emailAddress": user.emailAddress,
            "mobileNumber": user.mobileNumber,
            "type":user.type
        ]) { err in
            if err != nil{
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    
    func loginUser(user:UserModel,result: @escaping (_ authResult: Int?)->Void){
        if (user.emailAddress != "" && user.password != ""){
            Auth.auth().signIn(withEmail: user.emailAddress, password: user.password) { (response, error) in
                if error != nil {
                    if let errCode = FirebaseAuth.AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                            case .invalidCredential:
                                result(401)
                            case .wrongPassword:
                                result(401)
                            case .invalidEmail:
                                result(401)
                            default:
                                result(500)
                        }
                    }else{
                        result(500)
                    }
                }else {
                    UserDefaults.standard.set(true, forKey: "isLogged")
                    UserDefaults.standard.set(user.emailAddress, forKey: "emailAddress")
                    UserDefaults.standard.set(response?.user.uid, forKey: "uuid")
                    UserData.emailAddress=user.emailAddress
                    UserData.uuid=(response?.user.uid)!
                    result(200)
                }
            }
        }else{
            result(400)
        }
    }
    
    func fetchUser(user:UserModel,completion: @escaping (Int)->()){
        db.collection("users").document(user.emailAddress).getDocument { (document, error) in
            if let document = document, document.exists {
                let user = UserModel()
                user.emailAddress=document.get("emailAddress") as! String
                user.mobileNumber=document.get("mobileNumber") as! String
                user.type=document.get("type") as! Int
                
                UserDefaults.standard.set(user.mobileNumber, forKey: "mobileNumber")
                UserData.mobileNumber=user.mobileNumber
                completion(200)
            } else {
                completion(404)
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
            "timestamp":order.timestamp,
            "userId":order.userId
        ]){ err in
            if err != nil{
                completion(500)
            } else {
                FirebaseService().addNewOrderStatus(order: order)
                completion(201)
            }
        }
    }
    
    
    func getAllCategories(completion: @escaping (Any)->()){
        db.collection("categories").addSnapshotListener {
            querySnapshot, error in
            if let err = error {
                completion(500)
            }else{
                var categories:[CategoryModel]=[]
                for document in querySnapshot!.documents {
                    let categoryId=document.data()["categoryId"] as! String
                    let categoryName=document.data()["categoryName"] as! String
                    categories.append(CategoryModel(categoryId: categoryId, categoryName: categoryName))
                }
                populateCategoryListData(categories: categories)
                completion(categories)
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
        let ref = Database.database().reference().child("orders").child(UserData.uuid).child(order.orderId)
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
    
    func fetchItems(category:String="Other",completion: @escaping (Bool)->()) {
        var itemList:[Item]=[]
        db.collection("items").whereField("category", isEqualTo: category).whereField("isAvailable", isEqualTo: true).getDocuments() { (querySnapshot, err) in
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
        let ref = Database.database().reference().child("orders").child(UserData.uuid)
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
        let ref = Database.database().reference().child("orders").child(UserData.uuid).child(key).setValue(orderStatusData.asDictionary)
    }
    
    func updateOrderStatus(orderId:String,status:Int){
        let ref = Database.database().reference().child("orders").child(UserData.uuid).child(orderId)
        ref.updateChildValues(["status":status,"isRecieved":false])
    }
    
}
