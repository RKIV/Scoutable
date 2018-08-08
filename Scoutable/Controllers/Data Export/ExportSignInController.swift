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
        GTLRDriveHelper.findSpreadsheet(fileName: "Robotics SS") { (spreadsheet) in
            if let spreadsheet = spreadsheet{
                print("Found spreadsheet")
                GTLRDriveHelper.findFolder(folderName: "Robotics", complete: { (folder) in
                    print(folder ?? "No folder")
                    guard let folder = folder else { return }
                    GTLRDriveHelper.moveFile(fileID: spreadsheet.identifier!, folderID: folder.identifier!, complete: { (movedSpreadsheet) in
                        print(movedSpreadsheet?.parents ?? "No parents")
                    })
                })
            } else {
                GTLRSheetsHelper.createSpreadsheet(title: "Robotics SS") { (spreadsheet) in
                    guard let spreadsheet = spreadsheet else { return }
                    print(spreadsheet)
                    GTLRDriveHelper.findFolder(folderName: "Robotics", complete: { (folder) in
                        print(folder ?? "No folder")
                        guard let folder = folder else { return }
                        GTLRDriveHelper.moveFile(fileID: spreadsheet.spreadsheetId!, folderID: folder.identifier!, complete: { (movedSpreadsheet) in
                            print(movedSpreadsheet?.parents ?? "No parents")
                        })
                    })
                }
            }
        }
    }
    

    
    
}
