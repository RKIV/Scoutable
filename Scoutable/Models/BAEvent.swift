//
//  BAEventSimple.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation

struct BAEvent: Codable{
    var name: String
    var city: String?
    var state_prov: String?
    var country: String?
    var start_date: String
    var end_date: String
    var key: String
    var year: Int
}
