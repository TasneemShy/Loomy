//
//  Student.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import Foundation
import SwiftData

@Model
class Student {
    // MARK: - Stored Properties
    var name: String
    var notes: String = ""
    
    var phoneNumber: String?
    var parentName: String?
    var parentPhoneNumber: String?
    
    // MARK: - Relationships
    /// إذا حذفنا الطالب، كل سجلات حضوره ومستحقاته بتنحذف تلقائياً
    @Relationship(deleteRule: .cascade, inverse: \Attendance.student)
    var attendanceRecords: [Attendance] = []
    
    // MARK: - Initializer
    init(name: String,
         notes: String = "",
         phoneNumber: String? = nil,
         parentName: String? = nil,
         parentPhoneNumber: String? = nil) {
            self.name = name
            self.notes = notes
            self.phoneNumber = phoneNumber
            self.parentName = parentName
            self.parentPhoneNumber = parentPhoneNumber
        }
    
    // MARK: - Financial Computed Properties
    /// إجمالي المبلغ المتفق عليه (مجموع كل الحصص)
    var totalAgreed: Double {
        attendanceRecords.reduce(0) { $0 + $1.agreedRate }
    }
    
    /// إجمالي المبلغ المدفوع فعلياً
    var totalPaid: Double {
        attendanceRecords.reduce(0) { $0 + $1.amountPaid }
    }
    
    /// إجمالي الرصيد (موجب يعني إكسترا، سالب يعني نيد)
    var totalBalance: Double {
        attendanceRecords.reduce(0) { $0 + $1.balance }
    }
    
    /// نسخة ثانية من الرصيد (للتوافق مع الأكواد القديمة)
    var balance: Double {
        totalPaid - totalAgreed
    }
    
    // MARK: - Time Computed Properties
    /// الساعات الأونلاين
    var onlineHours: Double {
        attendanceRecords.filter { $0.session?.isOnline == true }
            .reduce(0) { $0 + ($1.session?.hours ?? 0) }
    }

    /// الساعات الوجاهية (Offline)
    var offlineHours: Double {
        attendanceRecords.filter { $0.session?.isOnline == false }
            .reduce(0) { $0 + ($1.session?.hours ?? 0) }
    }

    /// إجمالي الساعات (أونلاين + أوفلاين)
    var totalHours: Double {
        onlineHours + offlineHours
    }
}
