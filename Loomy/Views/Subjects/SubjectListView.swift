//
//  SubjectListView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct SubjectListView: View {
    // MARK: - Dependencies
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.name) private var subjects: [Subject]
    
    // MARK: - State Properties
    @State private var isShowingAddSheet = false

    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            List {
                ForEach(subjects) { subject in
                    NavigationLink(destination: SubjectDetailView(subject: subject)) {
                        SubjectRow(subject: subject)
                    }
                }
                .onDelete(perform: deleteSubjects)
                .listRowBackground(Color.theme.surface)
            }
            .navigationTitle("Subjects")
            .toolbar { toolbarContent }
            .sheet(isPresented: $isShowingAddSheet) { AddSubjectView() }
            .overlay { emptyStateOverlay }
            .applyLoomyTheme()
        }
    }
}

// MARK: - Subviews
extension SubjectListView {
    
    /// واجهة تظهر عندما لا توجد مواد مضافة
    @ViewBuilder
    private var emptyStateOverlay: some View {
        if subjects.isEmpty {
            ContentUnavailableView {
                Label("No Subjects", systemImage: "book.closed")
            } description: {
                Text("Add the subjects you teach and set your 4 different rates.")
            }
        }
    }
    
    /// أزرار التحكم العلوي
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Logic & Helpers
extension SubjectListView {
    private func deleteSubjects(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(subjects[index])
        }
    }
}

// MARK: - SubjectRow Component
struct SubjectRow: View {
    let subject: Subject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(subject.name)
                    .font(.headline)
                
                levelBadge
            }
            
            ratesSummaryText
        }
        .padding(.vertical, 2)
    }
    
    // وسم مستوى المادة (Uni/School)
    private var levelBadge: some View {
        Text(subject.isUniversity ? "Uni" : "School")
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(subject.isUniversity ? Color.theme.uni.opacity(0.1) : Color.theme.school.opacity(0.1))
            .foregroundColor(subject.isUniversity ? Color.theme.uni : Color.theme.school)
            .clipShape(Capsule())
    }
    
    // نص ملخص الأسعار الأربعة
    private var ratesSummaryText: some View {
        Text("Solo (\(subject.offlineSoloRate, specifier: "%.0f")/\(subject.onlineSoloRate, specifier: "%.0f"))  Group (\(subject.offlineGroupRate, specifier: "%.0f")/\(subject.onlineGroupRate, specifier: "%.0f")) ₪")
            .font(.caption2)
            .foregroundStyle(Color.theme.secondaryText)
    }
}

// MARK: - Preview
#Preview {
    SubjectListView()
}
