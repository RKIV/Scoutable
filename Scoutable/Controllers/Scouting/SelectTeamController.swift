//
//  selectTeamController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/6/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class SelectTeamsController: UITableViewController {
    private var currentPage = 0
    private var updating = false
    let searchController = UISearchController(searchResultsController: nil)
    var doneLoadingTeams = false
    var teamsArray: [BATeamSimple] = []
    var filteredTeams = [BATeamSimple]()
    var personalTeam: BATeamSimple?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl?.addTarget(self, action: #selector(refreshEnd), for: .valueChanged)
        searchController.searchBar.scopeButtonTitles = ["By Team Number", "By Team Name"]
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Teams"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        loadTeams{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updating = false
            }
            self.loadTeamsLoop {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    @objc func refreshEnd(){
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadTeamsLoop(complete: @escaping () -> ()){
        loadTeams {
            if !self.doneLoadingTeams{
                self.loadTeamsLoop {
                    complete()
                }
            } else {
                complete()
            }
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if User.current?.scoutTeam != nil{
            return true
        }
        return false
    }
    
    func loadTeams(complete: @escaping () -> ()) {
        BlueAllianceAPIService.teamList(page: currentPage) { (data) in
            if data.count != 0{
                self.teamsArray += data
                self.currentPage += 1
                complete()
            } else {
                self.doneLoadingTeams = true
                complete()
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "By Team Number") {
        filteredTeams = teamsArray.filter({( team : BATeamSimple) -> Bool in
            if scope == "By Team Number"{
                return String(team.team_number).contains(searchText)
            } else {
                return team.nickname.lowercased().contains(searchText.lowercased())
            }
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    
    @IBAction func topButtonTapped(_ sender: Any) {
        tableView.setContentOffset(.zero, animated:true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        tableView.deselectRow(at: indexPath!, animated: true)
        var teamNumber: Int = 0
        var teamSimple: BATeamSimple
        if isFiltering() {
            teamSimple = filteredTeams[(indexPath?.row)!]
        } else {
            teamSimple = teamsArray[(indexPath?.row)!]
        }
        teamNumber = teamSimple.team_number
        let destination = segue.destination as! StaticScoutingController
        destination.teamNumber = teamNumber
    }
    
    
    
}

extension SelectTeamsController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredTeams.count
        }
        return teamsArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
        var team: BATeamSimple
        if isFiltering(){
            team = filteredTeams[indexPath.row]
        } else {
            team = teamsArray[indexPath.row]
        }
        cell.teamName.text = team.nickname
        cell.teamNumber.text = String(team.team_number)
        cell.teamLocation.text = "\(team.city!) \(team.state_prov!) \(team.country!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension SelectTeamsController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    
}

extension SelectTeamsController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


