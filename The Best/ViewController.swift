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
    let calendar = Calendar.current
    var myBestAlbums = Set<UInt64>()
    var theOtherAlbumsByYear = [(key: Int, value: [String])]()
    
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var albumTable: UITableView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return theOtherAlbumsByYear.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(theOtherAlbumsByYear[row].key))
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        albumTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theOtherAlbumsByYear[yearPicker.selectedRow(inComponent: 0)].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = theOtherAlbumsByYear[yearPicker.selectedRow(inComponent: 0)].value[indexPath.row]
        return cell
    }
    
    func refreshLibrary() {
        // Which albums are the best?
        library = MPMediaQuery.playlists()
        for playlist in library.collections! {
            if (playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String).range(of: "^The Best ", options: .regularExpression) != nil {
                for song in playlist.items {
                    myBestAlbums.insert(song.albumPersistentID)
                }
            }
        }

        // Which albums aren't the best?
        library = MPMediaQuery.albums()
        var theOtherAlbums = Dictionary<Int, [String]>()
        for album in library.collections! {
            if !myBestAlbums.contains(album.items[0].albumPersistentID) {
                if album.items[0].releaseDate != nil {
                    let year = calendar.component(.year, from: album.items[0].releaseDate!)
                    if !theOtherAlbums.keys.contains(year) {
                        theOtherAlbums[year] = []
                    }
                    theOtherAlbums[year]!.append(album.items[0].albumTitle ?? "Title")
                }
            }
        }

        theOtherAlbumsByYear = theOtherAlbums.sorted(by: { $0.0 > $1.0 })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        yearPicker.delegate = self
        yearPicker.dataSource = self
        
        albumTable.delegate = self
        albumTable.dataSource = self

        refreshLibrary()
    }

}

