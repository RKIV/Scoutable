//
//  NSDate+isBetween.swift
//  Scoutable
//
//  Created by Robert Keller on 8/6/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

extension Date{
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
}
