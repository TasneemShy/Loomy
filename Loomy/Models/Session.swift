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
    // MARK: - Stored Properties
    var date: Date
    var hours: Double
    var isOnline: Bool
    
    // MARK: - Relationships
    /// إذا حذفت المادة، الحصة بتضل موجودة بس المادة بتصير nil
    @Relationship(deleteRule: .nullify)
    var subject: Subject?
    
    /// إذا حذفت الحصة، كل سجلات الحضور المرتبطة فيها بتنحذف تلقائياً
    @Relationship(deleteRule: .cascade, inverse: \Attendance.session)
    var attendanceRecords: [Attendance] = []
    
    // MARK: - Initializer
    init(
        date: Date = .now,
        hours: Double = 1.0,
        isOnline: Bool = false
    ) {
        self.date = date
        self.hours = hours
        self.isOnline = isOnline
    }
}
