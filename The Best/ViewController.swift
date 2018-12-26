//
//  ViewController.swift
//  The Best
//
//  Created by Daniel Morrison on 15/10/18.
//  Copyright © 2018 Daniel Morrison. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var library = MPMediaQuery()
    let calendar = Calendar.current
    var myBestAlbums = Set<UInt64>()
    var theOtherAlbumsByYear = [(key: Int, value: [MPMediaItemCollection])]()
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    @IBOutlet weak var albumTable: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return theOtherAlbumsByYear.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Add one row for summarising the year
        return theOtherAlbumsByYear[section].value.count + 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(theOtherAlbumsByYear[section].key)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if theOtherAlbumsByYear[indexPath.section].value.count == indexPath.row {
            // Return a cell summarising the number of albums in the year
            let cell = tableView.dequeueReusableCell(withIdentifier: "summary") ?? UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "summary")
            cell.textLabel?.text = String(theOtherAlbumsByYear[indexPath.section].value.count) + " albums"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .gray
            return cell
        } else {
            // Return a cell containing the album title, artist and artwork
            let cell = tableView.dequeueReusableCell(withIdentifier: "album") ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "album")
            if theOtherAlbumsByYear[indexPath.section].value[indexPath.row].items.count > 0 {
                cell.textLabel?.text = theOtherAlbumsByYear[indexPath.section].value[indexPath.row].items[0].albumTitle ?? "Title"
                cell.detailTextLabel?.text = theOtherAlbumsByYear[indexPath.section].value[indexPath.row].items[0].albumArtist ?? "Artist"
                cell.detailTextLabel?.textColor = .gray
                cell.imageView?.image = theOtherAlbumsByYear[indexPath.section].value[indexPath.row].items[0].artwork?.image(at: CGSize(width: 44, height: 44))
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // If the selected row is not a summary
        if theOtherAlbumsByYear[indexPath.section].value.count != indexPath.row {
            musicPlayer.setQueue(with: theOtherAlbumsByYear[indexPath.section].value[indexPath.row])
            musicPlayer.play()
            if UIApplication.shared.canOpenURL(URL(string: "music://")!) {
                UIApplication.shared.open(URL(string: "music://")!)
            }
        }
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
        var theOtherAlbums = Dictionary<Int, [MPMediaItemCollection]>()
        for album in library.collections! {
            if !myBestAlbums.contains(album.items[0].albumPersistentID) {
                if album.items[0].releaseDate != nil {
                    let year = calendar.component(.year, from: album.items[0].releaseDate!)
                    if !theOtherAlbums.keys.contains(year) {
                        theOtherAlbums[year] = []
                    }
                    theOtherAlbums[year]!.append(album)
                }
            }
        }

        theOtherAlbumsByYear = theOtherAlbums.sorted(by: { $0.0 > $1.0 })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        albumTable.delegate = self
        albumTable.dataSource = self

        refreshLibrary()
    }

}

