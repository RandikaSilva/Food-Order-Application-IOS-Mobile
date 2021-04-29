//
//  FoodViewController.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//


import UIKit
import MaterialComponents.MaterialButtons

class FoodViewController: UIViewController {
    @IBOutlet weak var imgFoodImage: UIImageView!
    @IBOutlet weak var lblFoodName: UILabel!
    @IBOutlet weak var lblFoodOffer: UILabel!
    @IBOutlet weak var lblFoodPrice: UILabel!
    @IBOutlet weak var txtvFoodDescription: UITextView!
    
    var itemDetails:Item = Item()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFloatingButton()
        imgFoodImage.imageFromServerURL(urlString: itemDetails.itemThumbnail)
        lblFoodName.text = itemDetails.itemName
        
        if itemDetails.itemDiscount == 0.0{
            lblFoodOffer.isHidden=true
        }else{
            lblFoodOffer.text=String(format:"%.2f", itemDetails.itemDiscount)
        }
        
        lblFoodPrice.text = "Rs: "+String(format:"%.2f", itemDetails.itemPrice)+" /="
        txtvFoodDescription.text = itemDetails.itemDescription
    }
    
    func setFloatingButton() {
        let floatingButton = MDCFloatingButton()
        floatingButton.mode = .expanded
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.setTitle("Add to cart", for: .normal)
        floatingButton.backgroundColor = .systemYellow
        floatingButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        view.addSubview(floatingButton)
        view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant:-50))
        view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .centerX , relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0))
    }
    
    @objc func tap(_ sender: Any) {
        addNewItem(item: CartModel(itemId: itemDetails.itemId,itemName:itemDetails.itemName, itemQty: 1,itemPrice:itemDetails.itemPrice, totalPrice: itemDetails.itemPrice))
        let storeViewController = storyboard?.instantiateViewController(withIdentifier:"StorePageView") as? StorePageViewController
        self.navigationController?.pushViewController(storeViewController!, animated: true)
    }
}

