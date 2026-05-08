//
//  Attendance.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import Foundation
import SwiftData

@Model
class Attendance {
    // MARK: - Stored Properties
    /// يمثل (سعر الساعة × عدد الساعات) كلياً للحصة الواحدة
    var agreedRate: Double
    var amountPaid: Double
    
    // MARK: - Relationships
    var student: Student?
    var session: Session?
    
    // MARK: - Initializer
    init(
        student: Student? = nil,
        session: Session? = nil,
        agreedRate: Double = 0,
        amountPaid: Double = 0
    ) {
        self.student = student
        self.session = session
        self.agreedRate = agreedRate
        self.amountPaid = amountPaid
    }
    
    // MARK: - Computed Properties
    /// الحسبة الصحيحة للرصيد في هذه الحصة
    /// (سالب) يعني الطالب مديون | (موجب) يعني دافع زيادة
    var balance: Double {
        amountPaid - agreedRate
    }
    
    /// لمعرفة إذا الحصة مدفوعة بالكامل أم لا
    var isFullyPaid: Bool {
        amountPaid >= agreedRate
    }
}
