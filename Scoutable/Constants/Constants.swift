//
//  FieldTypes.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation

enum FieldTypes: String{
    case Switch = "Boolean"
    case TextView = "TextView"
    case StepperNumber = "StepperNumber"
    case NumberPad = "NumberPad"
}

enum MimeTypes: String{
    case Folder = "application/vnd.google-apps.folder"
    case Spreadsheet = "application/vnd.google-apps.spreadsheet"
}

struct Constants{
    static let currentYearConstant = 2018
}
