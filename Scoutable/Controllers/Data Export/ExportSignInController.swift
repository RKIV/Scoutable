//
//  ExportSignInController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/7/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import GoogleAPIClientForREST


class ExportSignInController: UIViewController{
    override func viewDidLoad() {
        super .viewDidLoad()
    }
    
    
    @IBAction func buttonTapped(_ sender: Any) {
        GTLRSheetsHelper.createSheet(title: "Spreadsheet Test")
    }
    

    
    
}
