//
//  SessionsListView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct SessionsListView: View {
    // MARK: - Dependencies
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    
    // MARK: - State Properties
    @State private var isShowingAddSheet = false
    @State private var sortOption: SessionSortOption = .date
    @State private var selectedDate = Date() // التاريخ المختار

    // MARK: - Computed Properties
    private var displayedSessions: [Session] {
        // المرحلة الأولى: التصفية حسب التاريخ (Filtering)
        let filtered = sessions.filter { session in
            Calendar.current.isDate(session.date, inSameDayAs: selectedDate)
        }
        
        // المرحلة الثانية: الترتيب (Sorting)
        var result = filtered
        switch sortOption {
        case .date:
            // بما أنهم بنفس اليوم، الترتيب هنا سيكون حسب "الوقت" (الساعة)
            result.sort { $0.date > $1.date }
        case .subject:
            result.sort { ($0.subject?.name ?? "Z") < ($1.subject?.name ?? "Z") }
        case .online:
            result.sort { ($0.isOnline ? 0 : 1) > ($1.isOnline ? 0 : 1) }
        }
        
        return result
    }

    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. التقويم الذكي (مع النقاط المؤشرة)
                // استبدلنا DatePicker بـ LoomyCalendar اللي عملناه
                LoomyCalendar(selectedDate: $selectedDate)
                    .frame(height: 500) // طول مناسب للرؤية
                    .background(Color.theme.surface)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // 2. قائمة الحصص
                List {
                    if displayedSessions.isEmpty {
                        // حالة لا يوجد حصص (Empty State)
                        contentUnavailableView
                    } else {
                        // عرض الحصص المفلترة
                        Section("Sessions for \(selectedDate.formatted(date: .abbreviated, time: .omitted))") {
                            ForEach(displayedSessions) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    SessionRow(session: session)
                                }
                            }
                            .onDelete(perform: deleteSessions)
                            .listRowBackground(Color.theme.surface)
                        }
                    }
                }
                .applyLoomyTheme() // تطبيق الثيم الموحد (الخلفية والسطور)
            }
            .navigationTitle("Schedule")
            .background(Color.theme.background) // خلفية الصفحة كاملة
            .toolbar { toolbarContent }
            .sheet(isPresented: $isShowingAddSheet) { AddSessionView() }
        }
    }
}

// MARK: - Subviews
extension SessionsListView {
    
    /// واجهة تظهر عندما لا توجد حصص مسجلة
    @ViewBuilder
    private var emptyStateOverlay: some View {
        if sessions.isEmpty {
            ContentUnavailableView(
                "No Sessions",
                systemImage: "calendar.badge.plus",
                description: Text("Record your first tutoring session to start tracking.")
            )
        }
    }
    
    /// أزرار التحكم العلوي (الترتيب والإضافة)
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            // قائمة الترتيب
            Menu {
                Picker("Sort Sessions", selection: $sortOption) {
                    ForEach(SessionSortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle")
            }

            // زر إضافة حصة جديدة
            Button {
                isShowingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Logic & Helpers
extension SessionsListView {
    private var contentUnavailableView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(Color.theme.accent)
            Text("No Sessions Today")
                .font(.headline)
            Text("Tap another date or add a new session.")
                .font(.subheadline)
                .foregroundStyle(Color.theme.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .listRowBackground(Color.clear)
    }
    
    private func deleteSessions(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}

// MARK: - Supporting Types
enum SessionSortOption: String, CaseIterable {
    case date = "Latest"
    case subject = "Subject"
    case online = "Offline/Online"
}

// MARK: - SessionRow Component
struct SessionRow: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // السطر الأول: المادة والمستوى والتاريخ
            HStack {
                Text(session.subject?.name ?? "DELETED SUBJECT")
                    .font(.headline)
                
                levelBadge
                
                Spacer()
                
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(Color.theme.secondaryText)
            }
            
            // السطر الثاني: أسماء الطلاب وحالة الحصة
            HStack {
                if !session.attendanceRecords.isEmpty {
                    Text(session.attendanceRecords.compactMap { $0.student?.name }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(Color.theme.secondaryText)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    statusBadge(
                        text: session.isOnline ? "On" : "Off",
                        icon: session.isOnline ? "globe" : "house.fill",
                        color: session.isOnline ? Color.theme.online : Color.theme.offline
                    )
                    
                    let studentCount = session.attendanceRecords.count
                    statusBadge(
                        text: studentCount > 1 ? "\(studentCount)" : "1",
                        icon: studentCount > 1 ? "person.2.fill" : "person.fill",
                        color: studentCount > 1 ? Color.theme.group : Color.theme.solo
                    )
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    // وسم مستوى الدراسة
    private var levelBadge: some View {
        Text(session.subject?.isUniversity == true ? "Uni" : "School")
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(session.subject?.isUniversity == true ? Color.theme.uni.opacity(0.1) : Color.theme.school.opacity(0.1))
            .foregroundColor(session.subject?.isUniversity == true ? Color.theme.uni : Color.theme.school)
            .clipShape(Capsule())
    }
    
    // تصميم الوسوم الصغيرة (On/Off, Group/Solo)
    private func statusBadge(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.system(size: 9, weight: .bold))
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}
