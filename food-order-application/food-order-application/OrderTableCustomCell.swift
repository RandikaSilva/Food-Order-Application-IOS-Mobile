//
//  OrderTableCustomCell.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//


import UIKit


class OrderTableCustomCell: UITableViewCell {
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
}

class OrderViewController: UIViewController {
    @IBOutlet weak var tableOrderView: UITableView!
    @IBOutlet weak var noDataView: UIView!
    
    let firestoreDataService = FirebaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firestoreDataService.getAllOrders(){
            completion in
            
            self.tableOrderView.delegate=self
            self.tableOrderView.dataSource=self
            self.tableOrderView.isHidden = (OrderData.orderList.count == 0 ?true:false)
            self.noDataView.isHidden = (OrderData.orderList.count == 0 ?false:true)
            self.tableOrderView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.firestoreDataService.getAllOrders(){
            completion in
            
            self.tableOrderView.delegate=self
            self.tableOrderView.dataSource=self
            self.tableOrderView.isHidden = (OrderData.orderList.count == 0 ?true:false)
            self.noDataView.isHidden = (OrderData.orderList.count == 0 ?false:true)
            self.tableOrderView.reloadData()
        }
    }
}

extension OrderViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension OrderViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OrderData.orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:OrderTableCustomCell =  tableView.dequeueReusableCell(withIdentifier: "tblOrderData") as! OrderTableCustomCell
        cell.lblOrderId.text = Array(OrderData.orderList)[indexPath.row].value.orderId
        cell.lblOrderStatus.text = self.getStatusName(status: Array(OrderData.orderList)[indexPath.row].value.status)
        return cell
    }
    
    func getStatusName(status:Int)->String{
        if status==0{
            return "Pending"
        }else if status==1{
            return "Preparing"
        }else if status==2{
            return "Ready"
        }else if status==3{
            return "Ready"
        }else if status==4{
            return "Completed"
        }else if status==5{
            return "Rejected"
        }
        return ""
    }
}

