//
//  AlbumFullInfoViewController.swift
//  itunes_album_viewer
//
//  Created by   IvDin on 06.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import UIKit

class AlbumFullInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cover: AsyncImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var numberOfTracks: UILabel!
    @IBOutlet weak var tracksTable: UITableView!
    
    private var model : AlbumDetailes?
    
    var albumID : Int? {
        didSet {
            guard let albumID = albumID else {
                return
            }
            ItunesAPIManager.sharedInstance.getAlbumDetailes(for: albumID, onFailure: {
                
            }) { (model) in
                self.updateUI(with: model)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tracksTable.estimatedRowHeight = 75.0
        self.tracksTable.rowHeight = UITableView.automaticDimension
        self.tracksTable.delegate = self
        self.tracksTable.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.model else {return 0}
        return model.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath)
        
        if let cell = cell as? TrackCell {
            cell.model = self.model?.songs[indexPath.row]
        }
        
        return cell
    }
    
    func updateUI(with model: AlbumDetailes) {
        self.model = model
        self.tracksTable.reloadData()
        
        self.cover.loadAsyncFrom(url: model.albumInfo.artworkUrl100 ?? "")
        self.albumName.text = model.albumInfo.collectionName
        self.artistName.text = model.albumInfo.artistName
        self.genre.text = model.albumInfo.primaryGenreName
        self.numberOfTracks.text = "\(model.songs.count) tracks"
        
        if
            let releaseDate = ISO8601DateFormatter().date(from: model.albumInfo.releaseDate ?? "")
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY MMM d"
            self.releaseDate.text = formatter.string(from: releaseDate)
        }
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class TrackCell: UITableViewCell {
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var duration: UILabel!
    var model: SongEntity? {
        didSet {
            self.trackName.text = model?.trackName
            let duration = (model?.trackTimeMillis ?? 0) / 1000
            let seconds = duration % 60
            let minutes = duration / 60
            
            let ss = "\(seconds < 10 ? "0" : "")\(seconds)"
            let mm = "\(minutes < 10 ? "0" : "")\(minutes)"
            
            self.duration.text = "\(mm):\(ss)"
        }
    }
    
}
