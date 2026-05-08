//
//  SubjectListView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct SubjectListView: View {
    @Query(sort: \Subject.name) private var subjects: [Subject]
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(subjects) { subject in
                    VStack(alignment: .leading) {
                        Text(subject.name)
                            .font(.headline)
                        Text("Solo: \(subject.defaultSoloRate, specifier: "%.0f") | Group: \(subject.defaultGroupRate, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: deleteSubjects)
            }
            .navigationTitle("Subjects")
            .toolbar {
                Button(action: { isShowingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddSubjectView()
            }
            .overlay {
                if subjects.isEmpty {
                    ContentUnavailableView(
                        "No Subjects",
                        systemImage: "book.closed",
                        description: Text("Add the subjects you teach and their default rates.")
                    )
                }
            }
        }
    }

    private func deleteSubjects(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(subjects[index])
        }
    }
}

#Preview {
    SubjectListView()
}
