//
//  StudentDetailView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct StudentDetailView: View {
    // MARK: - Dependencies
    let student: Student
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State Properties
    @State private var selectedAttendance: Attendance?
    @State private var isShowingAddSession = false
    
    // MARK: - Main Body
    var body: some View {
        List {
            financialSummarySection
            sessionHistorySection
            notesSection
        }
        .navigationTitle(student.name)
        .toolbar { toolbarContent }
        .sheet(item: $selectedAttendance) { record in
            EditPaymentView(attendance: record)
        }
        .sheet(isPresented: $isShowingAddSession) {
            AddSessionView(preSelectedStudent: student)
        }
        .applyLoomyTheme()
    }
}

// MARK: - Subviews
extension StudentDetailView {
    
    // 1. القسم المالي (الرصيد وإحصائيات الساعات)
    private var financialSummarySection: some View {
        Section("Financial Summary") {
            HStack {
                Text("Current Balance")
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(student.totalPaid, specifier: "%.0f") / \(student.totalAgreed, specifier: "%.0f") ₪")
                        .font(.subheadline)
                        .bold()
                    
                    balanceBadge
                }
            }
            hoursStatsBar
        }
        .listRowBackground(Color.theme.surface)
    }
    
    // شريط إحصائيات الساعات (أفقي)
    private var hoursStatsBar: some View {
        HStack(alignment: .center) {
            hourStatItem(label: "Offline", value: student.offlineHours, color: Color.theme.offline)
            Divider().frame(height: 30)
            hourStatItem(label: "Online", value: student.onlineHours, color: Color.theme.online)
            Divider().frame(height: 30)
            hourStatItem(label: "Total", value: student.totalHours, color: .primary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }

    // خلية إحصائية واحدة
    private func hourStatItem(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.theme.secondaryText)
                .textCase(.uppercase)
            
            Text("\(value.formatted())")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }

    // وسم حالة الرصيد
    private var balanceBadge: some View {
        Group {
            if student.balance < 0 {
                Text("Need: \(abs(student.balance), specifier: "%.0f") ₪")
                    .foregroundColor(.red)
            } else if student.balance > 0 {
                Text("Extra: \(student.balance, specifier: "%.0f") ₪")
                    .foregroundColor(.green)
            } else {
                Text("Settled")
                    .foregroundStyle(Color.theme.secondaryText)
            }
        }
        .font(.caption2)
        .fontWeight(.bold)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            student.balance == 0 ? Color.gray.opacity(0.1) :
            (student.balance < 0 ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
        )
        .clipShape(Capsule())
    }
    
    // 2. قسم الملاحظات
    private var notesSection: some View {
        Section("Student Notes") {
            TextEditor(text: Bindable(student).notes)
                .frame(minHeight: 100)
                .font(.body)
                .overlay(
                    Group {
                        if student.notes.isEmpty {
                            Text("Add study plan, weaknesses, or contact info...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.leading, 4)
                                .padding(.top, 8)
                        }
                    }, alignment: .topLeading
                )
        }.listRowBackground(Color.theme.surface)
    }
    
    // 3. قسم سجل الحصص التاريخي
    private var sessionHistorySection: some View {
        Section("Session History") {
            if student.attendanceRecords.isEmpty {
                Text("No sessions recorded yet.")
                    .font(.caption)
                    .foregroundStyle(Color.theme.secondaryText)
            } else {
                let sortedRecords = student.attendanceRecords.sorted(by: {
                    ($0.session?.date ?? Date()) > ($1.session?.date ?? Date())
                })
                
                ForEach(sortedRecords) { record in
                    Button {
                        selectedAttendance = record
                    } label: {
                        historyRow(for: record)
                    }
                    .buttonStyle(.plain)
                }
            }
        }.listRowBackground(Color.theme.surface)
    }
    
    // سطر الحصة الواحدة في السجل
    private func historyRow(for record: Attendance) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(record.session?.subject?.name ?? "Unknown")
                    .font(.headline)
                
                if let isUni = record.session?.subject?.isUniversity {
                    Text(isUni ? "Uni" : "School")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .font(.system(size: 10, weight: .bold))
                        .background(isUni ? Color.theme.uni.opacity(0.1) : Color.theme.school.opacity(0.1))
                        .foregroundColor(isUni ? Color.theme.uni : Color.theme.school)
                        .clipShape(Capsule())
                    
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    if let isOnline = record.session?.isOnline {
                        statusBadge(text: isOnline ? "On" : "Off",
                                    icon: isOnline ? "globe" : "house.fill",
                                    color: isOnline ? Color.theme.online : Color.theme.offline)
                    }
                    
                    if let studentCount = record.session?.attendanceRecords.count {
                        statusBadge(text: studentCount > 1 ? "\(studentCount)" : "1",
                                    icon: studentCount > 1 ? "person.2.fill" : "person.fill",
                                    color: studentCount > 1 ? Color.theme.group : Color.theme.solo)
                    }
                }
            }
            financialDetailRow(for: record)
        }
        .padding(.vertical, 4)
    }
    
    // الوسوم الصغيرة (On/Off, Solo/Group)
    private func statusBadge(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.system(size: 10, weight: .bold))
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
    
    // تفاصيل المبلغ والتوقيت أسفل الحصة
    private func financialDetailRow(for record: Attendance) -> some View {
        HStack {
            Text(record.session?.date.formatted(date: .abbreviated, time: .omitted) ?? "")
            Text("•")
            Text("\(record.session?.hours.formatted() ?? "0")h")
            Spacer()
            Text("Paid: \(record.amountPaid, specifier: "%.0f")")
                .bold()
                .foregroundColor(record.amountPaid >= record.agreedRate ? Color.theme.profit : Color.theme.debt)
            Text("/")
            Text("\(record.agreedRate, specifier: "%.0f") ₪").bold()
        }
        .font(.caption)
        .foregroundStyle(Color.theme.secondaryText)
    }

    // محتوى الـ Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowingAddSession = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
