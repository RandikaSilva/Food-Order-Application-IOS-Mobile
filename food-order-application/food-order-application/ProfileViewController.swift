//
//  ProfileViewController.swift
//  food-order-application
//
//  Created by Lasitha on 2021-03-05.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var contact: UILabel!
    @IBOutlet weak var Logout: UIButton!
    @IBOutlet weak var email: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        email.text=UserData.emailAddress
        contact.text=UserData.mobileNumber
        
        self.Logout.addTarget(self, action: #selector(self.logout(sender:)), for: .touchUpInside)
    }
    
    @objc func logout(sender:UIButton){
        UserDefaults.standard.set(false, forKey: "isLogged")
        let storeTabBarController = self.storyboard?.instantiateViewController(withIdentifier:"LoginView") as? LoginController
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.leftBarButtonItem=nil
        self.navigationItem.hidesBackButton=true
        self.navigationController?.pushViewController(storeTabBarController!,animated: true)
    }
}
