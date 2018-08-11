//
//  DataAnalysisListController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/9/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit


class DataAnalysisListController: UITableViewController{
    @IBOutlet var addDataAnalysisView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func animateaddDataAnalysisViewIn(){
        self.view.addSubview(addDataAnalysisView)
        addDataAnalysisView.center.y = self.view.center.y - 100
        addDataAnalysisView.center.x = self.view.center.x
        addDataAnalysisView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addDataAnalysisView.alpha = 0
        addDataAnalysisView.layer.borderColor = UIColor.gray.cgColor
        addDataAnalysisView.layer.borderWidth = 3.0
        
        UIView.animate(withDuration: 0.4) {
            //            self.visualEffectView.effect = self.effect
            self.addDataAnalysisView.alpha = 1
            self.tableView.backgroundView?.alpha = 0.5
            self.addDataAnalysisView.transform = CGAffineTransform.identity
        }
    }
    
    func animateaddDataAnalysisViewOut(){
        UIView.animate(withDuration: 0.3, animations: {
            self.addDataAnalysisView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.tableView.backgroundView?.alpha = 1
            self.addDataAnalysisView.alpha = 0
            //            self.visualEffectView.effect = nil
        }) { (success) in
            self.addDataAnalysisView.removeFromSuperview()
        }
    }
    
    
    @IBAction func singleButtonTapped(_ sender: Any) {
        animateaddDataAnalysisViewOut()
        performSegue(withIdentifier: "toSingleAnalysis", sender: self)
    }
    
    @IBAction func multipleButtonTapped(_ sender: Any) {
        animateaddDataAnalysisViewOut()
        performSegue(withIdentifier: "toMultipleAnalysis", sender: self)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        animateaddDataAnalysisViewIn()
    }
    
    
    
    
}
