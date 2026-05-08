//
//  EditPaymentView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct EditPaymentView: View {
    // MARK: - Dependencies
    let attendance: Attendance
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    @State private var tempHours: Double = 0
    @State private var tempAgreedRate: Double = 0
    @State private var tempAmountPaid: Double = 0
    @State private var initialHourlyRate: Double = 0
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            Form {
                sessionTimeSection
                financialDetailsSection
            }
            .navigationTitle("Edit Info")
            .onAppear(perform: setupInitialData)
            .toolbar { toolbarContent }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Subviews
extension EditPaymentView {
    
    /// القسم الأول: تعديل وقت الحصة (يؤثر على السعر تلقائياً)
    private var sessionTimeSection: some View {
        Section("Session Time") {
            Stepper("Duration: \(tempHours.formatted(.number.precision(.fractionLength(0...1))))h",
                    value: $tempHours,
                    in: 0.5...10,
                    step: 0.5)
            .onChange(of: tempHours) {
                // تحديث المبلغ المتفق عليه تلقائياً بناءً على سعر الساعة الأصلي
                tempAgreedRate = initialHourlyRate * tempHours
            }
        }
    }
    
    /// القسم الثاني: التفاصيل المالية (المبلغ المتفق عليه والمدفوع)
    private var financialDetailsSection: some View {
        Section("Financial Details") {
            HStack {
                Text("Paid")
                Spacer()
                TextField("Paid", value: $tempAmountPaid, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.blue)
            }
            HStack {
                Text("Price")
                Spacer()
                TextField("Amount", value: $tempAgreedRate, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .bold()
            }
        }
    }
    
    /// أزرار التحكم (إلغاء وتأكيد)
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Done") { saveChanges() }
        }
    }
}

// MARK: - Logic & Helpers
extension EditPaymentView {
    
    /// تعبئة البيانات عند فتح الشاشة
    private func setupInitialData() {
        tempHours = attendance.session?.hours ?? 0
        tempAgreedRate = attendance.agreedRate
        tempAmountPaid = attendance.amountPaid
        
        if tempHours > 0 {
            initialHourlyRate = tempAgreedRate / tempHours
        }
    }
    
    /// حفظ التغييرات وتحديث الحصص المرتبطة
    private func saveChanges() {
        guard let session = attendance.session else { return }
        
        // 1. تحديث ساعات الحصة (يؤثر على الجميع)
        session.hours = tempHours
        
        // 2. تحديث المبالغ لبقية الطلاب في نفس الحصة (Group Logic)
        let isGroup = session.attendanceRecords.count > 1
        if let subject = session.subject {
            for record in session.attendanceRecords {
                let hourlyRate: Double
                if session.isOnline {
                    hourlyRate = isGroup ? subject.onlineGroupRate : subject.onlineSoloRate
                } else {
                    hourlyRate = isGroup ? subject.offlineGroupRate : subject.offlineSoloRate
                }
                record.agreedRate = hourlyRate * tempHours
            }
        }
        
        // 3. تأكيد القيم الخاصة بهذا الطالب (Overwrites)
        attendance.agreedRate = tempAgreedRate
        attendance.amountPaid = tempAmountPaid
        
        try? modelContext.save()
        dismiss()
    }
}
