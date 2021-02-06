//
//  ItunesAPIManager.swift
//  itunes_album_viewer
//
//  Created by   IvDin on 06.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import Foundation

class ItunesAPIManager {
    public static let sharedInstance = ItunesAPIManager()
    private let session = URLSession.shared
    
    
    func getAlbums(withRequest: String, onFailure: @escaping () -> Void, completion : @escaping (AlbumSearchResponse) -> Void) {
        let stringURL = "https://itunes.apple.com/search?term=\(generateURLEncodedSearchString(withRequest))&media=music&entity=album&attribute=albumTerm&explicit=Yes"
        
        guard let url = URL(string: stringURL) else {onFailure();return} //todo: add wrong request response
        
        dataTask(url: url, onFailure: {
            onFailure()
        }) { data in
            do {
                let response = try JSONDecoder().decode(AlbumSearchResponse.self, from: data)
                
                let albums = response.results.sorted()
                let result = AlbumSearchResponse(resultCount: response.resultCount, results: albums)
                
                completion(result)
            }
            catch {
                print(error)
                onFailure()
            }
        }
    }
    
    func getAlbumDetailes(for id: Int, onFailure: @escaping () -> Void, completion: @escaping (AlbumDetailes) -> Void) {
        let stringURL = "https://itunes.apple.com/lookup?id=\(id)&entity=song"
        
        guard let url = URL(string: stringURL) else {onFailure();return}
        
        dataTask(url: url, onFailure: {
            onFailure()
        }) { (data) in
            do {
                let response = try JSONDecoder().decode(AlbumDetailesResponse.self, from: data)
                
                // In response.result first element is album info and all other elements are songs
                
                guard
                    response.resultsCount > 1, //album info plus one or more songs
                    let albumInfo = AlbumEntity(from: response.results[0])
                else {onFailure(); return}
                
                var songs: [SongEntity] = []
                
                for entity in response.results {
                    if let song = SongEntity(from: entity) {
                        songs.append(song)
                    }
                }
                
                let detailes = AlbumDetailes(albumInfo: albumInfo, songs: songs)
                
                completion(detailes)
            }
            catch {
                print(error)
                onFailure()
            }
        }
    }
    
    // "word1 word2, word3:" -> "word1+word2+word3"
    internal func generateURLEncodedSearchString(_ s: String) -> String {
        
        let separatingCharecters: CharacterSet = CharacterSet.punctuationCharacters.union(.whitespacesAndNewlines)
        
        var words = s.components(separatedBy: separatingCharecters)
        words.removeAll {$0.isEmpty}
        
        return words.joined(separator: "+")
    }
    
    
    private func dataTask(url: URL, onFailure: @escaping () -> Void, completion: @escaping (Data) -> Void) {
        
        
        session.dataTask(with: url, completionHandler: {data, response, error in
            if let data = data {
                print("url: \(url.absoluteString)", "data: \(String(describing: String.init(data: data, encoding: .utf8)))")
            }
            if error != nil || data == nil {
                print("Client error!\nerror:\n\(String(describing: error))")
                DispatchQueue.main.async {
                    onFailure()
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("server error")
                DispatchQueue.main.async {
                    onFailure()
                }
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print("server error! response: \(response)")
                DispatchQueue.main.async {
                    onFailure()
                }
                return
            }
            guard let data = data else {return}
            DispatchQueue.main.async {
                completion(data)
            }
            }).resume()
    }
    
}


//struct with all fields from song and album json objects
fileprivate struct ItunesEntity: Codable {
    let wrapperType: String
    let collectionType: String?
    let artistId : Int
    let collectionId : Int
    let amgArtistId : Int?
    let artistName : String
    let collectionName : String
    let collectionCensoredName : String
    let artistViewUrl : String
    let collectionViewUrl : String
    let artworkUrl60 : String
    let artworkUrl100 : String
    let collectionPrice : Float
    let collectionExplicitness : String
    let trackCount : Int
    let copyright : String?
    let country : String
    let currency : String
    let releaseDate : String//"2010-09-24T07:00:00Z",
    let primaryGenreName : String
    let kind : String?
    let trackId : Int?
    let trackName : String?
    let trackCensoredName : String?
    let trackViewUrl : String?
    let previewUrl : String?
    let artworkUrl30 : String?
    let trackPrice : Float?
    let trackExplicitness : String?
    let discCount : Int?
    let discNumber : Int?
    let trackNumber : Int?
    let trackTimeMillis : Int?
    let isStreamable : Bool?
}


//song info
struct SongEntity: Codable {
    
    fileprivate init?(from: ItunesEntity) {
        guard from.kind == "song" else {return nil}
        
        self.wrapperType = from.wrapperType
        self.kind = from.kind!
        self.artistId = from.artistId
        self.collectionId = from.collectionId
        self.trackId = from.trackId!
        self.artistName = from.artistName
        self.collectionName = from.collectionName
        self.trackName = from.trackName!
        self.collectionCensoredName = from.collectionCensoredName
        self.trackCensoredName = from.trackCensoredName!
        self.artistViewUrl = from.artistViewUrl
        self.collectionViewUrl = from.collectionViewUrl
        self.trackViewUrl = from.trackViewUrl!
        self.previewUrl = from.previewUrl!
        self.artworkUrl30 = from.artworkUrl30!
        self.artworkUrl60 = from.artworkUrl60
        self.artworkUrl100 = from.artworkUrl100
        self.collectionPrice = from.collectionPrice
        self.trackPrice = from.trackPrice!
        self.releaseDate = from.releaseDate
        self.collectionExplicitness = from.collectionExplicitness
        self.trackExplicitness = from.trackExplicitness!
        self.discCount = from.discCount!
        self.discNumber = from.discNumber!
        self.trackCount = from.trackCount
        self.trackNumber = from.trackNumber!
        self.trackTimeMillis = from.trackTimeMillis!
        self.country = from.country
        self.currency = from.currency
        self.primaryGenreName = from.primaryGenreName
        self.isStreamable = from.isStreamable!
    }
    
    let wrapperType : String
    let kind : String
    let artistId : Int
    let collectionId : Int
    let trackId : Int
    let artistName : String
    let collectionName : String
    let trackName : String
    let collectionCensoredName : String
    let trackCensoredName : String
    let artistViewUrl : String
    let collectionViewUrl : String
    let trackViewUrl : String
    let previewUrl : String
    let artworkUrl30 : String
    let artworkUrl60 : String
    let artworkUrl100 : String
    let collectionPrice : Float
    let trackPrice : Float
    let releaseDate : String
    let collectionExplicitness : String
    let trackExplicitness : String
    let discCount : Int
    let discNumber : Int
    let trackCount : Int
    let trackNumber : Int
    let trackTimeMillis : Int
    let country : String
    let currency : String
    let primaryGenreName : String
    let isStreamable : Bool
}

struct AlbumEntity: Codable {
    
    fileprivate init?(from: ItunesEntity) {
        guard from.wrapperType == "collection" else {return nil}
        self.wrapperType = from.wrapperType
        self.collectionType = from.collectionType!
        self.artistId = from.artistId
        self.collectionId = from.collectionId
        self.amgArtistId = from.amgArtistId!
        self.artistName = from.artistName
        self.collectionName = from.collectionName
        self.collectionCensoredName = from.collectionCensoredName
        self.artistViewUrl = from.artistViewUrl
        self.collectionViewUrl = from.collectionViewUrl
        self.artworkUrl60 = from.artworkUrl60
        self.artworkUrl100 = from.artworkUrl100
        self.collectionPrice = from.collectionPrice
        self.collectionExplicitness = from.collectionExplicitness
        self.trackCount = from.trackCount
        self.copyright = from.copyright!
        self.country = from.country
        self.currency = from.currency
        self.releaseDate = from.releaseDate
        self.primaryGenreName = from.primaryGenreName
    }
    
    let wrapperType: String
    let collectionType: String
    let artistId : Int
    let collectionId : Int
    let amgArtistId : Int
    let artistName : String
    let collectionName : String
    let collectionCensoredName : String
    let artistViewUrl : String
    let collectionViewUrl : String
    let artworkUrl60 : String
    let artworkUrl100 : String
    let collectionPrice : Float
    let collectionExplicitness : String
    let trackCount : Int
    let copyright : String
    let country : String
    let currency : String
    let releaseDate : String//"2010-09-24T07:00:00Z",
    let primaryGenreName : String
}

extension AlbumEntity : Comparable, Equatable {
    static func < (lhs: AlbumEntity, rhs: AlbumEntity) -> Bool {
        return lhs.collectionName.lowercased() < rhs.collectionName.lowercased()
    }
}

//root struct for albums search
struct AlbumSearchResponse: Codable {
    let resultCount: Int
    let results: [AlbumEntity]
}


//root struct for songs in album
fileprivate struct AlbumDetailesResponse: Codable {
    let resultsCount: Int
    let results: [ItunesEntity]
}

//inner struct for convenience
struct AlbumDetailes {
    let albumInfo: AlbumEntity
    let songs: [SongEntity]
}
