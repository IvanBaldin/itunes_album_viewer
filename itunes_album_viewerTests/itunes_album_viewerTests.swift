//
//  itunes_album_viewerTests.swift
//  itunes_album_viewerTests
//
//  Created by   IvDin on 03.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import XCTest

@testable import itunes_album_viewer

class itunes_album_viewerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SearchHistoryManager.sharedInstance.dropHistoryTable()
    }
    
    
    func testAlbumSearchAPICall() throws {
        ItunesAPIManager.sharedInstance.getAlbums(withRequest: "primo victoria", onFailure: {
            XCTAssert(false, "failed")
        }) { (response) in
            
            let expectedAlbumName = "Primo Victoria"
            XCTAssert(response.results.contains { entity in
                entity.collectionName == expectedAlbumName
            }, "ok")
        }
    }
    
    func testGetAlbumDetailesAPICall() throws {
        ItunesAPIManager.sharedInstance.getAlbumDetailes(for: 1463539373, onFailure: {
            XCTAssert(false, "failed")
        }) { (album) in
            let expectedSongsCount = 15
            
            let recievedSongsCount = album.songs.count
            
            XCTAssertEqual(expectedSongsCount, recievedSongsCount)
        }
    }
    
    func testSearchHistoryManager() throws {
        let manager = SearchHistoryManager.sharedInstance
        
        let isAddingWasSucceeded =
                manager.addRequest("sdad") &&
                manager.addRequest("dddd") &&
                manager.addRequest("12345") &&
                manager.addRequest("sdad")
        
        if !isAddingWasSucceeded {XCTAssert(false, "adding rows to db failed")}
        
        let history = manager.getSearchHistory()
        
        let isGettingWasCorrect =
                history[0] == "sdad" &&
                history.count == 3
        
        XCTAssert(isGettingWasCorrect)
    }
}
