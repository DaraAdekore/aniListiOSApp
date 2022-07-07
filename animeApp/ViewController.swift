//
//  ViewController.swift
//  animeApp
//
//  Created by Dara on 2022-06-29.
//

import UIKit
import SwiftUI
import ApolloAPI
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    let searchController  = UISearchController()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var animeCollection:SearchAnimeQuery.Data?
    var media:[SearchAnimeQuery.Data.Page.Medium]?
    var filteredData:[SearchAnimeQuery.Data.Page.Medium] = []
    var network = Network()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.loadData()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
    }
    
    
    func loadData(search:String = "") {
        if !search.isEmpty{
            Network.shared.apollo.fetch(query: SearchAnimeQuery(search: search)){
                [weak self] result in
                
                //Make Sure ViewController Has not been deallocated
                guard let self = self else{
                    return
                }
                
                /*defer {
                 
                 }*/
                switch result {
                case .success(let graphQLResult):
                    if let animeData = graphQLResult.data {
                        DispatchQueue.main.async {
                            self.animeCollection = animeData
                            self.media = self.animeCollection?.page?.media as! [SearchAnimeQuery.Data.Page.Medium]
                            self.filteredData = self.media!
                            self.tableView.reloadData()
                        }
                    }
                    
                    if let errors = graphQLResult.errors {
                        let message = errors
                            .map { $0.localizedDescription }
                            .joined(separator: "\n")
                        
                        print(message)
                    }
                case .failure(let error):
                    
                    print(error.localizedDescription)
                }
            }
        }
    }
    func getTitle(media:SearchAnimeQuery.Data.Page.Medium) -> String{
        if let english = media.title?.english{
            return english
        }
        if let romaji = media.title?.romaji{
            return romaji
        }
        return ""
    }
    
    func getCoverArt(media: SearchAnimeQuery.Data.Page.Medium) -> String{
        if let coverArt = media.coverImage?.medium{
            return coverArt
        }
        return ""
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.title.text = getTitle(media: self.filteredData[indexPath.row])
        let url = URL(string: getCoverArt(media: filteredData[indexPath.row]))
        let data = try! Data(contentsOf: url!)
        cell.coverArt.image = UIImage(data: data)
        return cell
    }
    func filterData(searchText:String, media:[SearchAnimeQuery.Data.Page.Medium]) -> [SearchAnimeQuery.Data.Page.Medium]{
        var localFilteredData:[SearchAnimeQuery.Data.Page.Medium]? = []
        
        
        for media in media {
            if let englishTitle = media.title?.english{
                if let romajiTitle = media.title?.romaji{
                    if(englishTitle.lowercased().contains(searchText.lowercased()) && romajiTitle.lowercased().contains(searchText.lowercased())){
                        localFilteredData?.append(media)
                    }
                }
            }else if let romajiTitle = media.title?.romaji {
                if romajiTitle.contains(searchText) {
                    localFilteredData?.append(media)
                }
            }

        }
        return localFilteredData!
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(self.media != nil){
            if searchText == "" {
                self.filteredData = self.media!
            }
            else{
                self.filteredData = filterData(searchText: searchText, media: self.media!)
            }
        }
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadData(search:searchBar.text!)
        self.view.endEditing(true)
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.endEditing(true)
    }
    
    
    
}

