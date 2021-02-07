//
//  AsyncImageView.swift
//  itunes_album_viewer
//
//  Created by   IvDin on 07.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import UIKit

class AsyncImageView: UIImageView {
    static var imagesCacheDictionary: [NSString:UIImage] = [:] //todo: add clear of old images
    private var currentURL: NSString?
    var delegate : AsyncImageViewDelegate?
    
    
    func loadAsyncFrom(
        url: String,
        placeholder: UIImage? = AsyncImageView.getPlaceholder(fromColor: .clear)
    ) {
        let imageURL = url as NSString
        if let cashedImage = AsyncImageView.imagesCacheDictionary[imageURL] {
            print("imageURL = ", imageURL)
            image = cashedImage
            self.delegate?.imageDownloaded()
            return
        }
        image = placeholder
        currentURL = imageURL
        guard let requestURL = URL(string: url) else { image = placeholder; return }
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            DispatchQueue.main.async { [weak self] in
                if
                    error == nil,
                    let imageData = data,
                    self?.currentURL == imageURL,
                    let imageToPresent = UIImage(data: imageData)
                {
                    AsyncImageView.imagesCacheDictionary[imageURL] = imageToPresent
                    self?.image = imageToPresent
                    self?.delegate?.imageDownloaded()
                } else {
                    self?.image = placeholder
                }
            }
        }.resume()
    }
    
}
protocol AsyncImageViewDelegate {
    func imageDownloaded()
}
extension AsyncImageView {
    static func getPlaceholder(fromColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fill(rect)
        }
        
        return img
    }
}
