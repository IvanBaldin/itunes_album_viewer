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
    
    var albumToShow: AlbumEntity?
    
    var requestNeedToBeShown: SearchRequest?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        if let request = self.requestNeedToBeShown {
            self.requestNeedToBeShown = nil
            self.searchBar.text = request.request
            self.searchAlbums(with: request.request)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "album", for: indexPath)
        if let cell = cell as? AlbumCollectionCell {
            cell.setWidth(self.view.frame.width * 0.37)
            cell.setData(self.albums.results[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = (collectionView.cellForItem(at: indexPath) as? AlbumCollectionCell)?.model {
            albumToShow = model
            performSegue(withIdentifier: "show_album_detailes", sender: self)
        }
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if
            let destination = segue.destination as? AlbumFullInfoViewController,
            segue.identifier == "show_album_detailes"
        {
            destination.albumID = self.albumToShow?.collectionId
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
class AlbumCollectionCell: UICollectionViewCell {
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var author: UILabel!
    
    var model: AlbumEntity?
    
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
