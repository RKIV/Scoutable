//
//  BlueAllianceAPI.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation

struct BLueAllianceAPIService{
    static let authKey = "?X-TBA-Auth-Key=kBs60SNuL1nxdenLv33plVaEsQIexpDwN9nnrCNhHOy7KoOKjW7xzpaPtYQE9nPH"
    static let baseURL = "https://www.thebluealliance.com/api/v3"
    
    // MARK: Get Teams
    static func teamListSimple(page: Int, done: @escaping ([BATeamSimple]) -> ()){
        let urlString = "\(baseURL)/teams/\(page)/simple\(authKey)"
        guard let url = URL(string: urlString) else {return}
        decodeTeamsSimple(for: url) { (data) in
            done(data)
        }
    }
    static func teamListSimple(forDistrictKey districtKey: String, page: Int, done: @escaping ([BATeamSimple]) -> ()){
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
    
    // MARK: Get Events
    static func eventsListSimple(forTeamNumber teamNumber: Int, done: @escaping ([BAEventSimple]) -> ()){
        let urlString = "\(baseURL)/team/frc\(teamNumber)/events/simple\(authKey)"
        guard let url = URL(string: urlString) else {return}
        decodeEventsSimple(for: url) { (data) in
            done(data)
        }
    }
}

extension BLueAllianceAPIService{
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
    
    private static func decodeEventsSimple(for url: URL, decodingDone: @escaping ([BAEventSimple]) -> ()){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                let baTeamSimpleData = try JSONDecoder().decode([BAEventSimple].self, from: data)
                decodingDone(baTeamSimpleData)
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
}

