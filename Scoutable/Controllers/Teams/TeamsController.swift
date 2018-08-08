//
//  ViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleAPIClientForREST

class TeamsController: UITableViewController {
    private var currentPage = 0
    private var updating = false
    let searchController = UISearchController(searchResultsController: nil)
    var doneLoadingTeams = false
    var teamsArray: [BATeamSimple] = []
    var filteredTeams = [BATeamSimple]()
    var personalTeam: BATeamSimple?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshEnd), for: .valueChanged)
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
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.view.endEditing(true)
        if let currentUser = User.current{
            UserService.show(forUID: currentUser.uid) { (user) in
                if let user = user{
                    User.setCurrent(user)
                    self.loadPersonalTeam {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
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
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.loadTeamsLoop {
                    complete()
                }
            } else {
                complete()
            }
        }
    }
    
    func loadPersonalTeam(complete: @escaping () -> ()){
        if let teamNumber = User.current?.roboticsTeamNumber{
            BlueAllianceAPIService.teamSimple(forNumber: teamNumber) { (teamData) in
                self.personalTeam = teamData
                complete()
            }
        } else{
            if (User.current?.uid) != nil{
                UserService.show(forUID: (User.current?.uid)!, completion: { (user) in
                    if let teamNumber = user?.roboticsTeamNumber{
                        BlueAllianceAPIService.teamSimple(forNumber: teamNumber) { (teamData) in
                            self.personalTeam = teamData
                            complete()
                        }
                    } else {
                        complete()
                    }
                })
            } else{
                complete()
            }
        }
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
        let top = IndexPath.init(row: 0, section: 0)
        tableView.scrollToRow(at: top, at: .top, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        tableView.deselectRow(at: indexPath!, animated: true)
        var teamNumber: Int = 0
        var teamName: String = ""
        var teamSimple: BATeamSimple
        if isFiltering() {
            teamSimple = filteredTeams[(indexPath?.row)!]
        } else {
            teamSimple = teamsArray[(indexPath?.row)!]
        }
        
        switch indexPath?.section{
        case 0:
            teamNumber = (personalTeam?.team_number)!
            teamName = (personalTeam?.nickname)!
        case 1:
            teamNumber = teamSimple.team_number
            teamName = teamSimple.nickname
        default:
            print("Unexpected section")
        }
        let destination = segue.destination as! IndividualTeamController
        destination.teamNumber = teamNumber
        destination.teamName = teamName
        
    }
    

}

extension TeamsController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            if isFiltering() {
                return filteredTeams.count
            }
            return teamsArray.count
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            if let teamData = personalTeam{
                let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
                cell.teamName.text = teamData.nickname
                cell.teamNumber.text = String(teamData.team_number)
                cell.teamLocation.text = "\(teamData.city!) \(teamData.state_prov!) \(teamData.country!)"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noPersonalTeamCell") as! NoPersonalTeamCellView
                return cell
            }
        case 1:
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
        default:
            print("Unexected section")
            let defaultCell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
            return defaultCell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if section == 0 {
            label.text = "Your Team"
        } else {
            label.text = "All Teams"
        }
        
        v.addSubview(label)
        return v
    }
}

extension TeamsController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    
}

extension TeamsController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


