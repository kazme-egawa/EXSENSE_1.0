//
//  SecondViewController.swift
//  EXSENSE_1.0
//
//  Created by 江川主民 on 2017/10/31.
//  Copyright © 2017年 江川主民. All rights reserved.
//

import Foundation
import UIKit

class SecondViewController: UIViewController {

    // Init ColorPicker with white
    var selectedColor: UIColor = UIColor.white
    
    // IBOutlet for the ColorPicker
    @IBOutlet var colorPicker: SwiftHSVColorPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup Color Picker
        colorPicker.setViewColor(UIColor.white)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getSelectedColor(_ sender: UIButton) {
        print("\(UInt16(colorPicker.hue * 255)) \(UInt16(colorPicker.saturation * 255)) \(UInt16(colorPicker.brightness * 255))")
    }

}

