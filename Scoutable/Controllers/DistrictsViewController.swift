//
//  DistrictsViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/27/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class DistrictsViewController: UIViewController{
    
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var districtsTableView: UITableView!
    var districsArray = [BADistric]()
    var years: [Int] {
        get {
            var appendableYears = [Int]()
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let currentYear = dateFormatter.string(from: now)
            for year in 1992...Int(currentYear)!{
                appendableYears.append(year)
            }
            return appendableYears
        }
    }
    override func viewDidLoad() {
        super .viewDidLoad()
        yearPicker.delegate = self
        yearPicker.dataSource = self
        districtsTableView.dataSource = self
        print(years)
    }
    
    func loadDistricts(forYear year: Int, complete: @escaping () -> ()){
        BlueAllianceAPIService.districtsList(forYear: year) { (districts) in
            self.districsArray = districts!
            complete()
        }
    }
    
}

extension DistrictsViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(years[row])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loadDistricts(forYear: years[row]) {
            self.districtsTableView.reloadData()
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
        return districsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "districtCell") as! DistrictCellView
        cell.districtNameLabel.text = districsArray[indexPath.row].display_name
        return cell
        
    }
    
    
}
