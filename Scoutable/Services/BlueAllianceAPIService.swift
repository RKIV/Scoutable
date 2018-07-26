//
//  BlueAllianceAPI.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation

struct BLueAllianceAPIService{
    static let baseURL = "https://www.thebluealliance.com/api/v3"
    
    private static func decodeTeam(for url: URL, decodingDone: @escaping ([BATeamSimple]) -> ()){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                let baTeamSimpleData = try JSONDecoder().decode([BATeamSimple].self, from: data)
                decodingDone(baTeamSimpleData)
                //Get back to the main queue
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
    
    static func teamList(page: Int, done: @escaping ([BATeamSimple]) -> ()){
        let urlString = "\(baseURL)/teams/\(page)"
        guard let url = URL(string: urlString) else {return}
        decodeTeam(for: url) { (data) in
            done(data)
        }
        
        
    }
    
    static func teamList(forDistrictKey districtKey: String, page: Int, done: @escaping ([BATeamSimple]) -> ()){
        
        let urlString = "\(baseURL)/district/\(districtKey)/\(page)"
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                let baTeamSimpleData = try JSONDecoder().decode([BATeamSimple].self, from: data)
                done(baTeamSimpleData)
                //Get back to the main queue
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()

    }
    static func teamList(forEvent: String){
        
    }
}

