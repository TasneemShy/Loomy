//
//  SubjectListView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct SubjectListView: View {
    // جلب المواد مرتبة حسب الاسم
    @Query(sort: \Subject.name) private var subjects: [Subject]
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(subjects) { subject in
                    NavigationLink(destination: SubjectDetailView(subject: subject)) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(subject.name)
                                    .font(.headline)
                                
                                // نشان (Badge) للمستوى: جامعة أو مدرسة
                                Text(subject.isUniversity ? "Uni" : "School")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(subject.isUniversity ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                                    .foregroundColor(subject.isUniversity ? .blue : .orange)
                                    .clipShape(Capsule())
                            }
                            
                            // عرض الأسعار الوجاهية (كمثال سريع في القائمة)
                            Text("Offline Solo: \(subject.offlineSoloRate, specifier: "%.0f") ₪")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
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
                // حل مشكلة الـ "Generic parameter C" بالتأكد من وجود حاوية
                if subjects.isEmpty {
                    ContentUnavailableView {
                        Label("No Subjects", systemImage: "book.closed")
                    } description: {
                        Text("Add the subjects you teach and set your 4 different rates.")
                    }
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
