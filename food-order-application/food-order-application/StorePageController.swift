//
//  StorePageController.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//

import UIKit
import MaterialComponents.MaterialButtons

class CategoryViewCell:UICollectionViewCell{
    @IBOutlet weak var lblCategoryName: UILabel!
}

class StoreTableCustomCell: UITableViewCell {
    @IBOutlet weak var imgFoodImage: UIImageView!
    @IBOutlet weak var lblFoodName: UILabel!
    @IBOutlet weak var lblFoodDescription: UILabel!
    @IBOutlet weak var lblFoodPrice: UILabel!
    @IBOutlet weak var lblFoodDiscount: UILabel!
    
}

class CartTableCustomCell: UITableViewCell {
    @IBOutlet weak var lblCartFoodName: UILabel!
    @IBOutlet weak var stpFoodQty: UIStepper!
    @IBOutlet weak var lblCartFoodPrice: UILabel!
}

class StorePageViewController: UIViewController {
    @IBOutlet weak var stkCartArea: UIStackView!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var storeTableView: UITableView!
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var lblItemCount: UILabel!
    @IBOutlet weak var lblQtyCount: UILabel!
    @IBOutlet weak var clCategoryView: UICollectionView!
    @IBOutlet weak var selectedCategoryView: UIView!
    @IBOutlet weak var btnClearCart: UIButton!
    
    var floatingButton = MDCFloatingButton()
    var firebaseFoodData=FirebaseService()
    let firestoreDataService = FirebaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnClearCart.addTarget(self, action: #selector(self.clearCart(sender:)), for: .touchUpInside)
    }
    func showAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.setFloatingButton()
        FirebaseService().listenToOrderStatus()
        self.firestoreDataService.getAllCategories(){
            completion in
            if completion is [CategoryModel]{
                if CategoryData.categoryList.count != 0{
                    self.firestoreDataService.fetchItemsData(category: CategoryData.categoryList[0].categoryName){
                        completion in
                        if completion{
                            self.selectedCategoryView.isHidden=false
                            self.categoryView.isHidden=false
                            self.lblCategoryName.text=CategoryData.categoryList[0].categoryName
                            self.stkCartArea.isHidden = (CartData.cartItemList.count==0 ? true:false)
                            self.lblItemCount.text!=String(CartData.cartItemList.count)+" Items"
                            self.storeTableView.delegate=self
                            self.storeTableView.dataSource=self
                            self.cartTableView.delegate=self
                            self.cartTableView.dataSource=self
                            self.clCategoryView.delegate=self
                            self.clCategoryView.dataSource=self
                            self.storeTableView.reloadData()
                            self.clCategoryView.reloadData()
                        }
                    }
                }else{
                    self.selectedCategoryView.isHidden=true
                    self.categoryView.isHidden=true
                    self.stkCartArea.isHidden = (CartData.cartItemList.count==0 ? true:false)
                    self.lblItemCount.text!=String(CartData.cartItemList.count)+" Items"
                    self.storeTableView.delegate=self
                    self.storeTableView.dataSource=self
                    self.cartTableView.delegate=self
                    self.cartTableView.dataSource=self
                    self.clCategoryView.delegate=self
                    self.clCategoryView.dataSource=self
                    self.storeTableView.reloadData()
                    self.clCategoryView.reloadData()
                }
            }else{
                self.showAlert(title: "Ss", message: "sss")
            }
        }
    }
    
    func setFloatingButton() {
        floatingButton.mode = .expanded
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.setTitle("Order", for: .normal)
        floatingButton.backgroundColor = .systemYellow
        floatingButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        view.addSubview(floatingButton)
        view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant:-50))
        view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .centerX , relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0))
        floatingButton.isHidden=(CartData.cartItemList.count==0 ? true:false)
    }

    @IBAction func stpQtyUpdate(_ sender: UIStepper) {
        let itemId = sender.accessibilityIdentifier
        for item in CartData.cartItemList{
            if(String(item.itemId)==itemId){
                item.itemQty=Int(sender.value)
                item.totalPrice=item.itemPrice * Float(item.itemQty)
                print(item.totalPrice)
            }
        }
        cartTableView.reloadData()
    }
    
    @objc func clearCart(sender:UIButton){
        CartData.cartItemList.removeAll()
        self.stkCartArea.isHidden = (CartData.cartItemList.count==0 ? true:false)
    }
    
    @objc func tap(_ sender: Any) {
        if CartData.cartItemList.count != 0{
            let order = OrderModel(orderId: generateOrderId(), userEmailAddress: UserData.emailAddress, items: CartData.cartItemList, total: generateOrderTotal(), status: 0,userId: UserData.uuid)
            OrderData.orderList[order.orderId]=order
            
            self.firestoreDataService.addNewOrder(order: order){
                completion in
                
                if completion==201{
                    let orderViewController = self.storyboard?.instantiateViewController(withIdentifier:"OrderView") as? OrderViewController
                    CartData.cartItemList.removeAll()
                    self.navigationController?.pushViewController(orderViewController!, animated: true)
                }else{
                    self.showAlert(title: "Oops!", message: "Unable to place order. Please try again")
                }
                
            }
        }else{
            self.showAlert(title: "Oops!", message: "No any items in cart")
        }
    }
    
}

extension StorePageViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == storeTableView{
            let foodViewController = storyboard?.instantiateViewController(withIdentifier:"FoodView") as? FoodViewController
            foodViewController?.itemDetails = ItemData.itemList[indexPath.row]
            self.navigationController?.pushViewController(foodViewController!, animated: true)
        }
    }
}

extension StorePageViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == storeTableView{
            return ItemData.itemList.count
        }else if tableView == cartTableView{
            return CartData.cartItemList.count
        }else{
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if ItemData.itemList.count == 0 {
            self.storeTableView.setEmptyView(title: "No items for category", message: "Your items will display in here")
        } else {
            self.storeTableView.restore()
        }
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == storeTableView{
            let cell:StoreTableCustomCell =  tableView.dequeueReusableCell(withIdentifier: "tbvCell") as! StoreTableCustomCell
            cell.imgFoodImage.imageFromServerURL(urlString: ItemData.itemList[indexPath.row].itemThumbnail)
            cell.lblFoodName.text = ItemData.itemList[indexPath.row].itemName
            cell.lblFoodDescription.text = ItemData.itemList[indexPath.row].itemDescription
            cell.lblFoodPrice.text = String(format:"%.2f", ItemData.itemList[indexPath.row].itemPrice)
            
            if ItemData.itemList[indexPath.row].itemDiscount == 0.0{
                cell.lblFoodDiscount.isHidden=true
            }else{
                cell.lblFoodDiscount.text=String(format:"%.2f", ItemData.itemList[indexPath.row].itemDiscount)
            }
    
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
            cell.layer.masksToBounds = false
            return cell
        }else if tableView == cartTableView{
            let cell:CartTableCustomCell =  tableView.dequeueReusableCell(withIdentifier: "tbvCartCell") as! CartTableCustomCell
            cell.lblCartFoodName.text=CartData.cartItemList[indexPath.row].itemName
            cell.stpFoodQty.accessibilityIdentifier=String(CartData.cartItemList[indexPath.row].itemId)
            cell.lblCartFoodPrice.text=String(format:"%.2f", CartData.cartItemList[indexPath.row].totalPrice)
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
            cell.layer.masksToBounds = false
            return cell
        }else{
            let cell:UITableViewCell=UITableViewCell()
            return cell
        }
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        self.image = nil
        let urlStringNew = urlString.replacingOccurrences(of: " ", with: "%20")
        URLSession.shared.dataTask(with: NSURL(string: urlStringNew)! as URL, completionHandler: { (data, response, error) -> Void in

            if error != nil {
                print(error as Any)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })

        }).resume()
    }
}

extension StorePageViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.lblCategoryName.text=CategoryData.categoryList[indexPath.row].categoryName
        self.firestoreDataService.fetchItems(category: CategoryData.categoryList[indexPath.row].categoryName){
            completion in

            if completion{
                self.stkCartArea.isHidden = (CartData.cartItemList.count==0 ? true:false)
                self.setFloatingButton()
                self.lblItemCount.text!=String(CartData.cartItemList.count)+" Items"
                self.storeTableView.delegate=self
                self.storeTableView.dataSource=self
                self.cartTableView.delegate=self
                self.cartTableView.dataSource=self
                self.storeTableView.reloadData()
            }
        }
    }
}

extension StorePageViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoryData.categoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CategoryViewCellReuseIdentifier",
                                                         for: indexPath) as? CategoryViewCell {
            let name = CategoryData.categoryList[indexPath.row].categoryName
            cell.lblCategoryName.text=name
            
            cell.backgroundColor=UIColor.systemGray
            return cell
        }
        return UICollectionViewCell()
    }
}

extension StorePageViewController: UICollectionViewDelegateFlowLayout {
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let itemsPerRow:CGFloat = 4
            let hardCodedPadding:CGFloat = 5
            let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
            let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
            return CGSize(width: itemWidth, height: itemHeight)
        }
}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
