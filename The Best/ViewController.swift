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
    var library = [(key: Int, value: [MPMediaItemCollection])]()
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var albumTable: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return library.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library[section].value.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let count = library[section].value.count
        if count == 1 {
            return String(library[section].key) + "        " + String(count) + " album"
        } else {
            return String(library[section].key) + "        " + String(count) + " albums"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "album") ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "album")
        if library[indexPath.section].value[indexPath.row].items.count > 0 {
            cell.textLabel?.text = library[indexPath.section].value[indexPath.row].items[0].albumTitle ?? "Title"
            cell.detailTextLabel?.text = library[indexPath.section].value[indexPath.row].items[0].albumArtist ?? "Artist"
            cell.detailTextLabel?.textColor = .gray
            cell.imageView?.image = library[indexPath.section].value[indexPath.row].items[0].artwork?.image(at: CGSize(width: 44, height: 44))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        MPMusicPlayerController.systemMusicPlayer.setQueue(with: library[indexPath.section].value[indexPath.row])
        MPMusicPlayerController.systemMusicPlayer.play()
        if UIApplication.shared.canOpenURL(URL(string: "music://")!) {
            UIApplication.shared.open(URL(string: "music://")!)
        }
    }
    
    func refreshLibrary() {
        var query = MPMediaQuery()
        var myBestAlbums = Set<UInt64>()

        // Which albums are the best?
        query = MPMediaQuery.playlists()
        for playlist in query.collections! {
            if (playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String).range(of: "^The Best ", options: .regularExpression) != nil {
                for song in playlist.items {
                    myBestAlbums.insert(song.albumPersistentID)
                }
            }
        }

        // Which albums aren't the best?
        query = MPMediaQuery.albums()
        var theOtherAlbums = Dictionary<Int, [MPMediaItemCollection]>()
        for album in query.collections! {
            if !myBestAlbums.contains(album.items[0].albumPersistentID) {
                if album.items[0].releaseDate != nil {
                    let year = Calendar.current.component(.year, from: album.items[0].releaseDate!)
                    if !theOtherAlbums.keys.contains(year) {
                        theOtherAlbums[year] = []
                    }
                    theOtherAlbums[year]!.append(album)
                }
            }
        }

        library = theOtherAlbums.sorted(by: { $0.0 > $1.0 })
    }

    @objc func refresh() {
        refreshLibrary()
        albumTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        albumTable.refreshControl = refreshControl
        
        albumTable.delegate = self
        albumTable.dataSource = self

        refreshLibrary()
    }

}

