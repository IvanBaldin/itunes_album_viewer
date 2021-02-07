//
//  SearchHistoryManager.swift
//  itunes_album_viewer
//
//  Created by   IvDin on 07.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import Foundation
import SQLite

class SearchHistoryManager {
    static public let sharedInstance = SearchHistoryManager()
    private static let dbRelativePath = "search_history_db.sqlite3"
    private var db: Connection
       
    private let idColumn               = Expression<Int64>("id")
    private let searchRequestColumn    = Expression<String>("file_path")

    private let searchHistoryTable     = Table("search_history_table")
    
    init() {
        //connect to database
        //SQLite will attempt to create the database file if it does not already exist
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        do {
            db = try Connection("\(path)/\(Self.dbRelativePath)")
        }
        catch {
            fatalError("failed to connect to search history database in path: \(path)/\(Self.dbRelativePath)")
        }
        //create table if not exist
        do {
            try db.run(searchHistoryTable.create(ifNotExists: true) {t in
                t.column(idColumn, primaryKey: .autoincrement)
                t.column(searchRequestColumn)
            })
        }
        catch {
            
        }
    }
    /// Adds request string to database
    /// returns true if succeeded
    /// otherwise returns false
    func addRequest(_ request: String) -> Bool {
        do {
            try db.run(searchHistoryTable.insert(searchRequestColumn <- request))
            return true
        }
        catch {
            print(error)
            return false
        }
    }
    
    func getSearchHistory() -> [String] {
        do {
            var history: [String] = []
            for row in try db.prepare(searchHistoryTable) {
                history.append(row[searchRequestColumn])
            }
            return history.reversed()
        }
        catch {
            print(error)
            return []
        }
    }
    func clearHistoryTable() -> Bool {
        do {
            try db.run(searchHistoryTable.delete())
            return true
        }
        catch {
            print(error)
            return false
        }
    }
}
