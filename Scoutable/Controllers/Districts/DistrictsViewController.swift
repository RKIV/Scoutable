//
//  DistrictsViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/27/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class DistrictsViewController: UIViewController{
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var districtsTableView: UITableView!
    var districtsArray = [JSON]()
    private let refreshControl = UIRefreshControl()
    var currentYear: Int {
        get {
            var appendableYears = [Int]()
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let thisYear = dateFormatter.string(from: now)
            return Int(thisYear)!
        }
    }
    var years: [Int] {
        get {
            var appendableYears = [Int]()
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let thisYear = dateFormatter.string(from: now)
            for year in 1992...Int(thisYear)!{
                appendableYears.append(year)
            }
            return appendableYears.reversed()
        }
    }
    override func viewDidLoad() {
        if User.current == nil{
            navItem.backBarButtonItem?.isEnabled = false
            navItem.hidesBackButton = true
        } else {
            navItem.backBarButtonItem?.isEnabled = true
            navItem.hidesBackButton = false
        }
        super .viewDidLoad()
        if #available(iOS 10.0, *) {
            districtsTableView.refreshControl = refreshControl
        } else {
            districtsTableView.addSubview(refreshControl)
        }
        districtsTableView.refreshControl?.beginRefreshing()
        loadDistricts(forYear: currentYear) {
            DispatchQueue.main.async {
                self.districtsTableView.refreshControl?.endRefreshing()
                self.districtsTableView.reloadData()
            }
            
        }
        yearPicker.delegate = self
        yearPicker.dataSource = self
        districtsTableView.dataSource = self
        print(years)
    }
    
    func loadDistricts(forYear year: Int, complete: @escaping () -> ()){
        BlueAllianceAPIService.districtsList(forYear: year) { (districts) in
            self.districtsArray = districts.sorted {$0["display_name"] < $1["display_name"]}
            complete()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EventsController
        let indexPath = districtsTableView.indexPathForSelectedRow
        destination.districtKey = districtsArray[(indexPath?.row)!]["key"].rawValue as? String
        districtsTableView.deselectRow(at: districtsTableView.indexPathForSelectedRow!, animated: true)   
    }
    
    
}

extension DistrictsViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(years[row])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        districtsTableView.refreshControl?.beginRefreshing()
        loadDistricts(forYear: years[row]) {
            DispatchQueue.main.async {
                self.districtsTableView.reloadData()
                self.districtsTableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension DistrictsViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
}

extension DistrictsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if years.count <= 0{
            return 0
        }
        return districtsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "districtCell") as! DistrictCellView
        cell.districtNameLabel.text = districtsArray[indexPath.row]["display_name"].rawValue as? String
        return cell
        
    }
    
    
}
