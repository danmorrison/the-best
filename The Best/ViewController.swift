//
//  ViewController.swift
//  The Best
//
//  Created by Daniel Morrison on 15/10/18.
//  Copyright © 2018 Daniel Morrison. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var library = MPMediaQuery()
    var years: Set<Int> = []
    let calendar = Calendar.current
    
    @IBOutlet weak var yearPicker: UIPickerView!

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(yearPickerData[row]))
    }
    
    var yearPickerData: [Int] = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.yearPicker.delegate = self
        self.yearPicker.dataSource = self

        library = MPMediaQuery.albums()
        library.groupingType = MPMediaGrouping.album
        
        for item in library.items! {
            if item.releaseDate != nil {
                years.insert(calendar.component(.year, from: item.releaseDate!))
            }
        }
        
        self.yearPickerData = years.sorted(by: >)
    }

}

