//
//  Session.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import Foundation
import SwiftData

@Model
class Session {
    var date: Date
    var hours: Double
    var subject: Subject?
    
    @Relationship(deleteRule: .cascade, inverse: \Attendance.session)
    var attendanceRecords: [Attendance] = []
    
    init(date: Date = .now, hours: Double = 1.0) {
        self.date = date
        self.hours = hours
    }
}
