//
//  TextField.swift
//  FindDr
//
//  Created by eduardo milpas diaz on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

class TextField {
    class func customize(myView : UIView) {
        let textFields = myView.subviews.filter({(field : AnyObject) -> Bool in
            return field .isKindOfClass(UITextField)
        })
        for textField in textFields {
            changeProperties(textField as UITextField)
        }
    }


    class func changeProperties(textField : UITextField) {
            (textField as UITextField).layer.borderColor = UIColor(rgba: "#FFFFFF").CGColor
            (textField as UITextField).layer.borderWidth  = 1
            (textField as UITextField).layer.cornerRadius  = 10
            (textField as UITextField).borderStyle = UITextBorderStyle.RoundedRect
        }


}
