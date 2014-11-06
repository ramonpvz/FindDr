//
//  LoginViewController.swift
//  FindDr
//
//  Created by eduardo milpas diaz on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

class LoginViewController : UIViewController {

    //MARK - View Properties
    @IBOutlet var txtUser: UITextField!
    @IBOutlet var txtPassword: UITextField!


    //MARK - Overriden properties
    override func viewDidLoad() {
        super.viewDidLoad()
        TextField.customize(view)


    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //txtUser.layer.borderColor = UIColor(rgba: "#FFFFFF").CGColor
    }

}


