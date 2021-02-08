//
//  SearchViewController.swift
//  itunes_album_viewer
//
//  Created by   IvDin on 06.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var albumsView: UICollectionView!
    
    var albums = AlbumSearchResponse(resultCount: 0, results: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        albumsView.delegate = self
        albumsView.dataSource = self
        
        
        //enable dismissing keybord
        albumsView.keyboardDismissMode = .interactive
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.resultCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "album", for: indexPath)
        if let cell = cell as? AlbumCollectionCell {
            cell.setWidth(self.view.frame.width * 0.37)
            cell.setData(self.albums.results[indexPath.item])
        }
        return cell
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            self.searchAlbums(with: text)
        }
        searchBar.resignFirstResponder()
    }
    
    private func searchAlbums(with request: String) {
        _ = SearchHistoryManager.sharedInstance.addRequest(request)
        ItunesAPIManager.sharedInstance.getAlbums(withRequest: request, onFailure: {
            //todo: add some reaction for user
        }) { [weak self] (albumsResponse) in
            self?.albums = albumsResponse
            self?.updateUI()
        }
    }
    
    func updateUI() {
        albumsView.reloadData()
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
class AlbumCollectionCell: UICollectionViewCell {
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var author: UILabel!
    
    private var model: AlbumEntity?
    
    func setWidth(_ w: CGFloat) {
        widthConstraint?.constant = w
    }
    func setData(_ model: AlbumEntity) {
        self.model = model
        (self.cover as? AsyncImageView)?.loadAsyncFrom(url: model.artworkUrl100 ?? "")
        self.album?.text = model.collectionName
        self.author?.text = model.artistName
    }
}
