//
//  SearchHistoryViewController.swift
//  itunes_album_viewer
//
//  Created by   IvDin on 06.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import UIKit

class SearchHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var historyTable: UITableView!
    
    private var model: [SearchRequest]! {
        didSet {
            self.historyTable.reloadData()
        }
    }
    private var requestToShow: SearchRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        historyTable.delegate = self
        historyTable.dataSource = self
        historyTable.estimatedRowHeight = 75
        historyTable.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        model = SearchHistoryManager.sharedInstance.getSearchHistory().map {SearchRequest(request: $0)}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history_cell", for: indexPath)
        
        if let cell = cell as? HistoryTableCell {
            cell.model = self.model[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.requestToShow = (tableView.cellForRow(at: indexPath) as? HistoryTableCell)?.model
        if self.requestToShow != nil {
            self.performSegue(withIdentifier: "show_albums_with_request", sender: self)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? SearchViewController, segue.identifier == "show_albums_with_request" {
            destination.requestNeedToBeShown = self.requestToShow
        }
    }
}

class HistoryTableCell: UITableViewCell {
    @IBOutlet weak var requestLabel: UILabel!
    var model: SearchRequest? {
        didSet {
            self.requestLabel.text = model?.request
        }
    }
}
struct SearchRequest {
    let request: String
}
