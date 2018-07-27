//
//  BATeam.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation

class BATeam: Codable{
    var key: String
    var team_number: Int
    var nickname: String
    var name: String
    var city: String?
    var state_prov: String?
    var country: String?
    var rookie_year: Int
    var motto: String?
    var website: String?
}
