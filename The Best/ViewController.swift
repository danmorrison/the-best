//
//  ViewController.swift
//  The Best
//
//  Created by Daniel Morrison on 15/10/18.
//  Copyright © 2018 Daniel Morrison. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    var library = MPMediaQuery()
    var years: Set<Int> = []
    let calendar = Calendar.current
    var yearPickerData = [Int]()
    var myBestAlbums = Set<UInt64>()
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func refreshLibrary() {
        library = MPMediaQuery.playlists()
        
        for playlist in library.collections! {
            if (playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String).range(of: "^The Best ", options: .regularExpression) != nil {
                for song in playlist.items {
                    myBestAlbums.insert(song.albumPersistentID)
                }
            }
        }
        
        library = MPMediaQuery.albums()
        
        for album in library.collections! {
            if !myBestAlbums.contains(album.items[0].albumPersistentID) {
                if album.items[0].releaseDate != nil {
                    years.insert(calendar.component(.year, from: album.items[0].releaseDate!))
                }
            }
        }
        
        yearPickerData = years.sorted(by: >)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        yearPicker.delegate = self
        yearPicker.dataSource = self

        refreshLibrary()
    }

}

