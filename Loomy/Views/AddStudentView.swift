//
//  AddStudentView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct AddStudentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // عشان نسكر الشاشة بعد الحفظ

    // متغيرات لإدخال البيانات
    @State private var name = ""
    @State private var subject = ""
    @State private var offlineRate = ""
    @State private var onlineRate = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Student Information") {
                    TextField("Student Name", text: $name)
                    TextField("Subject", text: $subject)
                }
                
                Section("Hourly Rates") {
                    TextField("Offline", text: $offlineRate)
                        .keyboardType(.decimalPad)
                    TextField("Online", text: $onlineRate)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Student")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStudent()
                    }
                    .disabled(name.isEmpty) // ما بنحفظ إذا الاسم فاضي
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveStudent() {
        let newStudent = Student(
            name: name,
            subject: subject,
            offlineRate: Double(offlineRate) ?? 0.0,
            onlineRate: Double(onlineRate) ?? 0.0
        )
        modelContext.insert(newStudent) // حفظ في قاعدة البيانات
        dismiss()
    }
}

#Preview {
    AddStudentView()
}
