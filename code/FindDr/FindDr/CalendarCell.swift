//
//  CalendarCell.swift
//  calendario3
//
//  Created by eduardo milpas diaz on 11/10/14.
//  Copyright (c) 2014 globant. All rights reserved.
//

import Foundation
import UIKit



class CalendarCell : UICollectionViewCell {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    let textLabel: UILabel!
    let imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        //imageView = UIImageView(frame: CGRect(x: 0, y: 16, width: frame.size.width, height: frame.size.height*2/3))
        //imageView.contentMode = UIViewContentMode.ScaleAspectFit
        //contentView.addSubview(imageView)

        let textFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        textLabel = UILabel(frame: textFrame)
        textLabel.font = UIFont.systemFontOfSize(CGFloat(8))//UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        textLabel.textAlignment = .Center
        textLabel.numberOfLines = 1
        contentView.addSubview(textLabel)
    }


    func dayCellFormat(reg : Int) {
        switch reg {
        case 1: setLabelText("Lun")
        case 2: setLabelText("Mar")
        case 3: setLabelText("Mie")
        case 4: setLabelText("Jue")
        case 5: setLabelText("Vie")
        case 6: setLabelText("Sab")
        case 7: setLabelText("Dom")
        default: setLabelText("WTF")
        }

        contentView.backgroundColor = UIColor(red: 176/255, green: 11/255, blue: 62/255, alpha: 0.9)
        setLabelfontcolor()
    }

    func hourCellFormat(reg : Int) {
        setLabelText("\(24 - reg)-\(24 - (reg - 1))")
        contentView.backgroundColor = UIColor(red: 0/255, green: 181/255, blue: 251/255, alpha: 0.9)
        setLabelfontcolor()
    }

    func cruisedCellFormat() {
        setLabelText("Horas")
        
        contentView.backgroundColor = UIColor(red: 58/255, green: 58/255, blue: 58/255, alpha: 1)
        setLabelfontcolor()
    }

    func setLabelfontcolor() {
        for vista in contentView.subviews {
            if vista.isKindOfClass(UILabel) {
                (vista as UILabel).textColor = UIColor.whiteColor()
            }
        }
    }

    func setLabelText(text : String) {
        for vista in contentView.subviews {
            if vista.isKindOfClass(UILabel) {
                (vista as UILabel).text = CalendarCell.getFormattedHour(text)
            }
        }
    }

    func makeSelection() {
        let selectedColor = UIColor(red: 131/255, green: 211/255, blue: 15/255, alpha: 1)
        if contentView.backgroundColor == selectedColor {
            contentView.backgroundColor = UIColor.whiteColor()
            self.selected = false
        }
        else {
            contentView.backgroundColor = selectedColor
            self.selected = true
        }
    }

    func isSelected() -> Bool {
        let selectedColor = UIColor(red: 131/255, green: 211/255, blue: 15/255, alpha: 1)
        if contentView.backgroundColor == selectedColor {
            return true
        }
        return false
    }

    class func getFormattedHour(hour: String) -> String {
        var arr: Array<String> = hour.componentsSeparatedByString("-")
        if arr.count >= 2 {
            if countElements(arr[0]) < 2 {
                arr[0] = "0\(arr[0])"
            }
            if countElements(arr[1]) < 2 {
                arr[1] = "0\(arr[1])"
            }
            return "\(arr[0])-\(arr[1])"
        }
        return hour
    }
}


