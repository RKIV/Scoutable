//
//  NoteCellView.swift
//  Scoutable
//
//  Created by Robert Keller on 7/29/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class NoteCellView: UITableViewCell{
    var cellID: String?
    var roboticsTeam: Int?
    var dynamic = false
    var matchID: String?
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
}

extension NoteCellView: UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        if dynamic {
            ScoutDataService.addDynamicScoutField(name: titleLabel.text!, type: FieldTypes.TextView.rawValue, cellID: cellID!, value: textView.text, roboticsTeam: roboticsTeam!, matchID: matchID!, scoutTeam: (User.current?.scoutTeam)!)
        } else {
            ScoutDataService.addStaticScoutField(name: titleLabel.text!, type: FieldTypes.TextView.rawValue, cellID: cellID!, value: textView.text, roboticsTeam: roboticsTeam!, year: Constants.currentYearConstant, scoutTeam: (User.current?.scoutTeam)!)
        }

    }
    
}
