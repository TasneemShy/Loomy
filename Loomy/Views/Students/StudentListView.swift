//
//  StudentListView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct StudentListView: View {
    @Query(sort: \Student.name) private var students: [Student]
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(students) { student in
                    NavigationLink(destination: StudentDetailView(student: student)) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(student.name).font(.headline)
                                    if let lastRecord = student.attendanceRecords.sorted(by: { ($0.session?.date ?? Date.distantPast) > ($1.session?.date ?? Date.distantPast) }).first,
                                                   let isUni = lastRecord.session?.subject?.isUniversity {
                                                    Text(isUni ? "Uni" : "School")
                                                        .font(.caption2)
                                                        .foregroundColor(isUni ? .blue : .orange)
                                                        .padding(.horizontal, 4)
                                                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(isUni ? Color.blue : Color.orange, lineWidth: 0.5))
                                                }
                                }
                            }
                            Spacer()
                            // عرض الرصيد (Need/Extra)
                            Text("\(student.totalBalance, specifier: "%.0f") ₪")
                                .foregroundColor(student.totalBalance >= 0 ? .green : .red)
                        }
                    }
                }
                .onDelete(perform: deleteStudents)
            }
            .navigationTitle("Students")
            .toolbar {
                Button(action: { isShowingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddStudentView()
            }
            .overlay {
                if students.isEmpty {
                    ContentUnavailableView(
                        "No Sessions",
                        systemImage: "person.2",
                        description: Text("Add your first Student to start tracking.")
                    )
                }
            }
        }
    }

    private func deleteStudents(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(students[index])
        }
    }
}
#Preview {
    StudentListView()
}
