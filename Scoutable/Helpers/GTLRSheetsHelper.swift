//
//  GTLRSheetsService.swift
//  Scoutable
//
//  Created by Robert Keller on 8/7/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST.GTLRSheets
import GoogleAPIClientForREST.GTLRSheetsService
import GoogleAPIClientForREST.GTLRSheetsQuery
import GoogleAPIClientForREST.GTLRSheetsObjects

struct GTLRSheetsHelper{
    static var service: GTLRSheetsService?
    
    
    
    static func createSpreadsheet(title: String, complete: @escaping (GTLRSheets_Spreadsheet?) -> ()){
        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject: GTLRSheets_Spreadsheet())
        query.bodyObject = GTLRObject.init(json: ["properties" : ["title" : title]])
        service?.executeQuery(query) { (ticket, results, error) in
            if let error = error{
                print("Could not create spreadsheet: \(error.localizedDescription)")
                complete(nil)
                return
            }
            if let results = results as? GTLRSheets_Spreadsheet {
                complete(results)
            } else {
                print("Unable to convert results to type GTLRSheets_Spreashsheet")
                complete(nil)
            }
        }
    }
    
    
    
}
