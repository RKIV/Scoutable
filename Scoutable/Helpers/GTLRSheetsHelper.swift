//
//  GTLRSheetsService.swift
//  Scoutable
//
//  Created by Robert Keller on 8/7/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST

struct GTLRSheetsHelper{
    static var service: GTLRSheetsService?
    
    
    static func createSheet(title: String){
        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject: GTLRSheets_Spreadsheet())
        query.bodyObject = GTLRObject.init(json: ["properties" : ["title" : title]])
        service?.executeQuery(query) { (ticket, results, error) in
            print(results ?? "No Results")
            return
        }
    }
    
    static func moveSheet(sheetID: String){
        
    }
    
    
    
}
