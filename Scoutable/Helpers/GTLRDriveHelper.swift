//
//  GTLRDriveHelper.swift
//  Scoutable
//
//  Created by Robert Keller on 8/8/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST.GTLRDrive
import GoogleAPIClientForREST.GTLRDriveService
import GoogleAPIClientForREST.GTLRDriveQuery
import GoogleAPIClientForREST.GTLRDriveObjects

struct GTLRDriveHelper{
    static var service: GTLRDriveService?
    
    
    static func createFolder(folderName: String, complete: @escaping (GTLRDrive_File?) -> ()){
        let folder = GTLRDrive_File()
        folder.mimeType = MimeTypes.Folder.rawValue
        folder.name = folderName
        let createQuery = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        service?.executeQuery(createQuery, completionHandler: { (ticket, results, error) in
            if let error = error{
                print(error.localizedDescription)
                complete(nil)
                return
            }
            if let results = results as? GTLRDrive_File{
                complete(results)
            } else {
                complete(nil)
                print("Unable to convert results to type GTLRDrive_File")
            }
        })
    }
    
    static func findFolder(folderName: String, complete: @escaping (GTLRDrive_File?) -> ()){
        let getQuery = GTLRDriveQuery_FilesList.query()
        getQuery.corpora = "user"
        getQuery.orderBy = "folder"
        service?.executeQuery(getQuery, completionHandler: { (ticket, results, error) in
            if let error = error{
                print(error.localizedDescription)
                complete(nil)
                return
            }
            
            if let results = results as? GTLRDrive_FileList{
                for file in results.files!{
                    if file.mimeType == MimeTypes.Folder.rawValue && file.name == folderName{
                        complete(file)
                        return
                    }
                }
                complete(nil)
                print("No file of such name")
            } else {
                complete(nil)
                print("Unable to convert results to type GTLRDrive_FileList")
            }
        })
    }
    
    static func getFile(fileID: String, complete: @escaping (GTLRDrive_File?) -> ()){
        let getQuery = GTLRDriveQuery_FilesGet.query(withFileId: fileID)
        service?.executeQuery(getQuery, completionHandler: { (ticket, results, error) in
            if let error = error{
                print(error.localizedDescription)
                complete(nil)
                return
            }
            if let results = results as? GTLRDrive_File{
                complete(results)
            } else {
                complete(nil)
                print("Unable to convert results to type GTLRDrive_File")
            }
        })
    }
    
    static func findSpreadsheet(fileName: String, complete: @escaping (GTLRDrive_File?) -> ()){
        let getQuery = GTLRDriveQuery_FilesList.query()
        getQuery.corpora = "user"
        getQuery.orderBy = "modifiedTime"
        service?.executeQuery(getQuery, completionHandler: { (ticket, results, error) in
            if let error = error{
                print(error.localizedDescription)
                complete(nil)
                return
            }
            
            if let results = results as? GTLRDrive_FileList{
                for file in results.files!{
                    if file.mimeType == MimeTypes.Spreadsheet.rawValue && file.name == fileName{
                        complete(file)
                        return
                    }
                }
                complete(nil)
                print("No file of such name")
            } else {
                complete(nil)
                print("Unable to convert results to type GTLRDrive_FileList")
            }
        })
    }
    
    static func moveFile(fileID: String, folderID: String, complete: @escaping (GTLRDrive_File?) -> ()){
        getFile(fileID: fileID) { (file) in
            guard let file = file else { return }
            let currentParents = file.parents?.joined(separator: ",")
            let updateQuery = GTLRDriveQuery_FilesUpdate.query(withObject: file, fileId: fileID, uploadParameters: nil)
            updateQuery.bodyObject?.json?.removeObject(forKey: "id")
            updateQuery.fileId = fileID
            updateQuery.fields = "id, parents"
            updateQuery.removeParents = currentParents
            updateQuery.addParents = folderID
            service?.executeQuery(updateQuery, completionHandler: { (ticket, results, error) in
                if let error = error{
                    print("Unable to move file: ", error.localizedDescription)
                    complete(nil)
                    return
                }
                
                if let results = results as? GTLRDrive_File{
                    print(results)
                    complete(results)
                } else {
                    print("Unable to convert results to type GTLRDrive_File")
                    complete(nil)
                }
                
            })
        }
    }
    
    
    
}
