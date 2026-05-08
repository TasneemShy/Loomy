//
//  DataExtensions.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 24/04/2026.
//

import Foundation

// MARK: - Student Array Extensions
extension Array where Element == Student {
    
    /// إجمالي الديون الكلية على جميع الطلاب
    /// تجمع فقط القيم السالبة (المبالغ التي لم تُدفع بعد)
    var totalGlobalDebt: Double {
        self.reduce(0) { $0 + ($1.totalBalance < 0 ? abs($1.totalBalance) : 0) }
    }
    
    /// إجمالي المبالغ الزائدة (الطلاب الذين دفعوا مقدماً)
    /// تجمع فقط القيم الموجبة
    var totalGlobalExtra: Double {
        self.reduce(0) { $0 + ($1.totalBalance > 0 ? $1.totalBalance : 0) }
    }
}

// MARK: - Attendance Array Extensions
extension Array where Element == Attendance {
    
    /// إجمالي الأرباح الفعلية
    /// يمثل كل قرش دخل جيبك فعلياً من جميع الحصص
    var totalActualEarnings: Double {
        self.reduce(0) { $0 + $1.amountPaid }
    }
}
