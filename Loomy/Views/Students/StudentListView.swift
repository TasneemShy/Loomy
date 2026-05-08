//
//  StudentListView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct StudentListView: View {
    // MARK: - Dependencies
    @Query(sort: \Student.name) private var students: [Student]
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State Properties
    @State private var searchText = ""
    @State private var isShowingAddSheet = false
    @State private var sortOption: SortOption = .name

    // MARK: - Computed Properties
    /// منطق الفلترة والترتيب المدمج
    var filteredAndSortedStudents: [Student] {
        // 1. الفلترة حسب البحث
        var result = students.filter { student in
            searchText.isEmpty || student.name.localizedCaseInsensitiveContains(searchText)
        }
        
        // 2. الترتيب حسب الخيار المختار
        switch sortOption {
        case .name:
            result.sort { $0.name < $1.name }
        case .debt:
            // المدينون (الرصيد السالب الأقل) أولاً
            result.sort { $0.totalBalance < $1.totalBalance }
        case .recent:
            // الأحدث تاريخاً في الحصص يظهر أولاً
            result.sort { (s1, s2) -> Bool in
                let date1 = s1.attendanceRecords.compactMap { $0.session?.date }.max() ?? .distantPast
                let date2 = s2.attendanceRecords.compactMap { $0.session?.date }.max() ?? .distantPast
                return date1 > date2
            }
        }
        return result
    }
    
    var groupedStudents: [(key: Character, value: [Student])] {
        // 1. فلترة الطلاب أولاً حسب البحث
        let filtered = filteredAndSortedStudents
        
        // 2. تجميعهم حسب أول حرف
        let grouped = Dictionary(grouping: filtered) { student in
            student.name.first?.uppercased().first ?? "#"
        }
        
        // 3. تحويلهم لـ Array مرتبة عشان الـ List يقبلهم
        return grouped.sorted { $0.key < $1.key }
    }

    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            List {
                if sortOption == .name && searchText.isEmpty {
                    // الحالة 1: تقسيم أبجدي (فقط عند الترتيب بالاسم وبدون بحث)
                    ForEach(groupedStudents, id: \.key) { section in
                        Section(header: Text(String(section.key))) {
                            ForEach(section.value) { student in
                                studentLink(for: student)
                            }
                        }
                    }
                    .onDelete(perform: deleteStudents)
                    .listRowBackground(Color.theme.surface)
                } else {
                    ForEach(filteredAndSortedStudents) { student in
                        NavigationLink(destination: StudentDetailView(student: student)) {
                            StudentRow(student: student)
                        }
                    }
                    .onDelete(perform: deleteStudents)
                    .listRowBackground(Color.theme.surface)
                }
            }
            .navigationTitle("Students")
            .searchable(text: $searchText, prompt: "Search for a student...")
            .toolbar { toolbarContent }
            .sheet(isPresented: $isShowingAddSheet) { AddStudentView() }
            .overlay { emptyStateView }
            .applyLoomyTheme()
        }
    }
}

// MARK: - Subviews
extension StudentListView {
    
    // دالة مساعدة لتجنب تكرار الكود
    private func studentLink(for student: Student) -> some View {
        NavigationLink(destination: StudentDetailView(student: student)) {
            StudentRow(student: student)
        }
    }
    
    /// واجهة تظهر عندما تكون قائمة الطلاب فارغة
    @ViewBuilder
    private var emptyStateView: some View {
        if students.isEmpty {
            ContentUnavailableView(
                "No Students",
                systemImage: "person.2",
                description: Text("Add your first Student to start tracking.")
            )
        }
    }

    /// أزرار التحكم العلوي (الترتيب والإضافة)
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            // قائمة خيارات الترتيب
            Menu {
                Picker("Sort By", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle")
            }

            // زر إضافة طالب جديد
            Button {
                isShowingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Logic & Helpers
extension StudentListView {
    private func deleteStudents(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(students[index])
        }
    }
}

// MARK: - Supporting Types
enum SortOption: String, CaseIterable {
    case name = "Name"
    case debt = "Debt"
    case recent = "Latest"
}

// MARK: - StudentRow Component
struct StudentRow: View {
    let student: Student
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(student.name)
                        .font(.headline)
                    badgeView
                }
                // إظهار الأرقام إذا كانت موجودة
                    if let displayInfo = formattedContactInfo {
                        Text(displayInfo)
                            .font(.caption2)
                            .foregroundStyle(Color.theme.secondaryText)
                            .lineLimit(1)
                        }
            }
            
            Spacer()
            
            financialSummaryView
        }
    }
    
    /// وسم الجامعة أو المدرسة (آمن من الكراش)
    @ViewBuilder
    private var badgeView: some View {
        let validRecords = student.attendanceRecords.filter { $0.session != nil }
        
        if let lastRecord = validRecords.sorted(by: { ($0.session?.date ?? .distantPast) > ($1.session?.date ?? .distantPast) }).first,
           let subject = lastRecord.session?.subject {
            
            let isUni = subject.isUniversity
            
            Text(isUni ? "Uni" : "School")
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 1.5)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isUni ? Color.theme.uni : Color.theme.school)
                .clipShape(Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isUni ? Color.theme.uni : Color.theme.school, lineWidth: 0.5)
                )
        } else {
            EmptyView()
        }
    }
    
    /// ملخص الرصيد المالي وحالة الدفع
    private var financialSummaryView: some View {
        VStack(alignment: .trailing) {
            Text("\(student.totalBalance, specifier: "%.0f") ₪")
                .font(.subheadline)
                .bold()
                .foregroundColor(student.totalBalance >= 0 ? Color.theme.profit : Color.theme.debt)
            
            HStack(spacing: 4) {
                Text("\(student.totalPaid, specifier: "%.0f")")
                Text("/")
                Text("\(student.totalAgreed, specifier: "%.0f")")
                Text("₪")
            }
            .font(.caption)
            .foregroundStyle(Color.theme.secondaryText)
        }
    }
    
    // دالة مساعدة لتنسيق النص (رقم الطالب ، رقم الأهل)
    private var formattedContactInfo: String? {
        var info: [String] = []
        
        // 1. إضافة رقم الطالب إذا وجد
        if let phone = student.phoneNumber, !phone.isEmpty {
            info.append(phone)
        }
        
        // 2. إضافة معلومات ولي الأمر (الاسم + الرقم) إذا وجدوا
        if let parentPhone = student.parentPhoneNumber, !parentPhone.isEmpty {
            if let pName = student.parentName, !pName.isEmpty {
                // شكل النص: "اسم الأهل: الرقم"
                info.append("\(pName): \(parentPhone)")
            } else {
                // في حال وجود الرقم بدون اسم
                info.append(parentPhone)
            }
        }
        
        return info.isEmpty ? nil : info.joined(separator: " , ")
    }
}

// MARK: - Preview
#Preview {
    StudentListView()
}
