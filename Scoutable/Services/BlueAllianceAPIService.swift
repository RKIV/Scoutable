//
//  BlueAllianceAPI.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BlueAllianceAPIService{
    static let authKey = "?X-TBA-Auth-Key=kBs60SNuL1nxdenLv33plVaEsQIexpDwN9nnrCNhHOy7KoOKjW7xzpaPtYQE9nPH"
    static let baseURL = "https://www.thebluealliance.com/api/v3"
    
    // MARK: Get Teams
    static func teamList(page: Int, done: @escaping ([BATeamSimple]) -> ()){
        let urlString = "\(baseURL)/teams/\(page)/simple\(authKey)"
        guard let url = URL(string: urlString) else {return}
        decodeTeamsSimple(for: url) { (data) in
            done(data)
        }
    }
    
    static func teamList(forDistrictKey districtKey: String, page: Int, done: @escaping ([BATeamSimple]) -> ()){
        let urlString = "\(baseURL)/district/\(districtKey)/\(page)/simple\(authKey)"
        guard let url = URL(string: urlString) else {return}
        decodeTeamsSimple(for: url) { (data) in
            done(data)
        }

    }
    
    static func teamSimple(forNumber teamNumber: Int, done: @escaping (BATeamSimple) -> ()){
        let urlString = "\(baseURL)/team/frc\(teamNumber)/simple\(authKey)"
        guard let url = URL(string: urlString) else {return}
        decodeTeamSimple(for: url) { (data) in
            done(data)
        }
    }
    
    static func team(forNumber teamNumber: Int, done: @escaping (BATeam) -> ()){
        let urlString =  "\(baseURL)/team/frc\(teamNumber)\(authKey)"
        guard let url = URL(string: urlString) else {return}
        decodeTeam(for: url) { (data) in
            done(data)
        }
    }
    
    static func team(forTeamKey teamKey: String, done: @escaping (JSON) -> ()){
        let urlString =  "\(baseURL)/team/\(teamKey)\(authKey)"
        guard let url = URL(string: urlString) else {return}
        swiftyJson(forURL: url) { (data) in
            done(data)
        }
    }
    
    static func teams(forEvent eventKey: String, done: @escaping (JSON) -> ()){
        let urlString = "\(baseURL)/event/\(eventKey)/teams/simple\(authKey)"
        guard let url = URL(string: urlString) else {return}
        swiftyJson(forURL: url) { (swiftyData) in
            done(swiftyData)
        }
    }
    
    static func rankings(forEvent eventKey: String, done: @escaping (JSON) -> ()){
        let urlString = "\(baseURL)/event/\(eventKey)/rankings\(authKey)"
        guard let url = URL(string: urlString) else {return}
        swiftyJson(forURL: url) { (swiftyData) in
            done(swiftyData)
        }
    }
    // MARK: Get Events
    static func eventsList(forTeamNumber teamNumber: Int, done: @escaping ([BAEvent]) -> ()){
        let urlString = "\(baseURL)/team/frc\(teamNumber)/events\(authKey)"
        guard let url = URL(string: urlString) else {return}
        decodeEventsSimple(for: url) { (data) in
            done(data)
        }
    }
    
    static func eventsList(forDistrict district: String, done: @escaping (JSON) -> ()){
        let urlString = "\(baseURL)/district/\(district)/events\(authKey)"
        guard let url = URL(string: urlString) else {return}
        swiftyJson(forURL: url) { (swiftyData) in
            done(swiftyData)
        }
    }
    
    // MARK: Get Districts
    static func districtsList(forYear year: Int, done: @escaping ([JSON]) -> ()){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: now)
        guard year >= 1992 && year <= Int(currentYear)! else {return}
        let urlString = "\(baseURL)/districts/\(year)\(authKey)"
        guard let url = URL(string: urlString) else {return}
        swiftyJson(forURL: url) { (swiftyData) in
            done(swiftyData.array!)
        }
        
    }

    static func maxTeam(complete: @escaping (Int) -> ()){
        var max = 0
        for i in 10...20{
            maxTeamOnPage(pgNum: i) { (num) in
                if num > max {
                    max = num
                }
                if i == 20 {
                    complete(max)
                }
            }
        }
    }
    
    static func matchesSimple(eventKey: String, done: @escaping (JSON) -> ()){
        let urlString = "\(baseURL)/event/\(eventKey)/matches/simple\(authKey)"
        guard let url = URL(string: urlString) else {return}
        swiftyJson(forURL: url) {swiftyData in
            done(swiftyData)
        }
    }
    
    
}

extension BlueAllianceAPIService{
    private static func decodeTeamsSimple(for url: URL, decodingDone: @escaping ([BATeamSimple]) -> ()){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                let baTeamSimpleData = try JSONDecoder().decode([BATeamSimple].self, from: data)
                let filteredData = baTeamSimpleData.filter({ (item) -> Bool in
                    if item.nickname == "Team \(item.team_number)"{
                        return false
                    }
                    return true
                })
                //                print(filteredData)
                print("Decodng Teams Done")
                decodingDone(filteredData)
                //Get back to the main queue
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
    
    private static func decodeTeamSimple(for url: URL, decodingDone: @escaping (BATeamSimple) -> ()){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let baTeamSimpleData = try JSONDecoder().decode(BATeamSimple.self, from: data)
                decodingDone(baTeamSimpleData)
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
    
    private static func decodeEventsSimple(for url: URL, decodingDone: @escaping ([BAEvent]) -> ()){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let baEventData = try JSONDecoder().decode([BAEvent].self, from: data)
                decodingDone(baEventData)
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
    
    private static func decodeTeam(for url: URL, decodingDone: @escaping (BATeam) -> ()){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let baTeamSimpleData = try JSONDecoder().decode(BATeam.self, from: data)
                decodingDone(baTeamSimpleData)
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
    
    private static func decodeTeamKeys(for pgNum: Int, decodingDone: @escaping ([String]) -> ()){
        let urlString = "\(baseURL)/teams/\(pgNum)/keys\(authKey)"
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let keys = try JSONDecoder().decode([String].self, from: data)
                decodingDone(keys)
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
    
    private static func maxTeamOnPage(pgNum: Int, complete: @escaping (Int) -> ()){
        
        BlueAllianceAPIService.decodeTeamKeys(for: pgNum) { (returnedKeys) in
            _ = pgNum
            if returnedKeys.count > 0{
                complete(Int(String((returnedKeys.last?.split(separator: "c")[1])!))!)
            } else {
                complete(0)
            }
        }
    }
    
    private static func swiftyJson(forURL url: URL, swiftyDone: @escaping (JSON) -> ()){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            do{
                let swiftyData = try JSON(data: data)
                swiftyDone(swiftyData)
            } catch {
                print("swiftyJson threw")
            }
            }.resume()
        
    }
}

