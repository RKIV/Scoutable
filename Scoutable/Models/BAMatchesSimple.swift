//
//  BAMatchesSimple.swift
//  Scoutable
//
//  Created by Robert Keller on 7/27/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import SwiftyJSON

class BAMatchesSimple: Codable{
    var actual_time: Int
    var alliances: [[String]]
}
{
    actual_time: 1491689987,
    alliances: {
    blue: {
    dq_team_keys: [ ],
    score: 305,
    surrogate_team_keys: [ ],
    team_keys: [
    "frc244",
    "frc5015",
    "frc4191"
    ]
    },
    red: {
    dq_team_keys: [ ],
    score: 392,
    surrogate_team_keys: [ ],
    team_keys: [
    "frc1482",
    "frc2122",
    "frc4334"
    ]
    }
    },
    comp_level: "f",
    event_key: "2017abca",
    key: "2017abca_f1m1",
    match_number: 1,
    predicted_time: 1491689941,
    set_number: 1,
    time: 1491688800,
    winning_alliance: "red"

