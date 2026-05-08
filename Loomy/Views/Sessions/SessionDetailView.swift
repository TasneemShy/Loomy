//
//  SessionDetailView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    // MARK: - Dependencies
    @Bindable var session: Session
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State Properties
    @State private var selectedAttendance: Attendance?

    // MARK: - Main Body
    var body: some View {
        List {
            sessionInfoSection
            attendanceSection
        }
        .navigationTitle("Session Details")
        .sheet(item: $selectedAttendance) { record in
            EditPaymentView(attendance: record)
        }
        .applyLoomyTheme()
    }
}

// MARK: - Subviews
extension SessionDetailView {
    
    /// القسم الأول: معلومات الحصة الأساسية (المادة، التوقيت، المدة)
    private var sessionInfoSection: some View {
        Section("Session Info") {
            HStack {
                Label("Subject", systemImage: "book")
                Spacer()
                Text(session.subject?.name ?? "Unknown")
                    .bold()
            }
            
            HStack {
                Label("Level", systemImage: "graduationcap")
                Spacer()
                Text(session.subject?.isUniversity == true ? "University" : "School")
                    .foregroundStyle(session.subject?.isUniversity == true ? Color.theme.uni : Color.theme.school)
            }
            
            Toggle(isOn: $session.isOnline) {
                Label("Online Session", systemImage: "globe")
            }
            .onChange(of: session.isOnline) { recalculateAttendanceRates() }
            
            DatePicker("Date", selection: $session.date, displayedComponents: .date)
            
            Stepper("Duration: \(session.hours.formatted(.number.precision(.fractionLength(0...1))))h",
                    value: $session.hours, in: 0.5...10, step: 0.5)
            .onChange(of: session.hours) { recalculateAttendanceRates() }
        }.listRowBackground(Color.theme.surface)
    }
    
    /// القسم الثاني: قائمة الطلاب وحالة الدفع لكل طالب
    private var attendanceSection: some View {
        Section("Attendance & Payments") {
            if session.attendanceRecords.isEmpty {
                Text("No students added to this session.")
                    .font(.caption)
                    .foregroundStyle(Color.theme.secondaryText)
            } else {
                ForEach(session.attendanceRecords) { record in
                    attendanceRow(for: record)
                }
            }
        }.listRowBackground(Color.theme.surface)
    }
    
    /// تصميم سطر الطالب داخل القائمة
    private func attendanceRow(for record: Attendance) -> some View {
        Button {
            selectedAttendance = record
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(record.student?.name ?? "Unknown Student")
                        .font(.headline)
                    
                    Text(record.amountPaid >= record.agreedRate ? "Paid in Full" : "Pending: \(record.agreedRate - record.amountPaid, specifier: "%.0f") ₪")
                        .font(.caption2)
                        .foregroundColor(record.amountPaid >= record.agreedRate ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(record.amountPaid, specifier: "%.0f") / \(record.agreedRate, specifier: "%.0f") ₪")
                        .font(.subheadline)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(Color.theme.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Logic & Helpers
extension SessionDetailView {
    
    /// تحديث المبالغ المستحقة لجميع الطلاب عند تغيير إعدادات الحصة
    private func recalculateAttendanceRates() {
        guard let subject = session.subject else { return }
        let isGroup = session.attendanceRecords.count > 1
        
        for record in session.attendanceRecords {
            let hourlyRate: Double
            
            if session.isOnline {
                hourlyRate = isGroup ? subject.onlineGroupRate : subject.onlineSoloRate
            } else {
                hourlyRate = isGroup ? subject.offlineGroupRate : subject.offlineSoloRate
            }
            
            record.agreedRate = hourlyRate * session.hours
        }
    }
}
