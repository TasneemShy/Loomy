//
//  AddStudentView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct AddStudentView: View {
    // MARK: - Dependencies
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var parentName = ""
    @State private var parentPhoneNumber = ""

    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Student Name", text: $name)
                        .textInputAutocapitalization(.words)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    }.listRowBackground(Color.theme.surface)
                                
                Section("Parent Info (Optional)") {
                    TextField("Parent Name", text: $parentName)
                    TextField("Parent Phone", text: $parentPhoneNumber)
                        .keyboardType(.phonePad)
                    }.listRowBackground(Color.theme.surface)
            }
            .navigationTitle("New Student")
            .toolbar { toolbarContent }
            .applyLoomyTheme()
        }
    }
}

// MARK: - Subviews
extension AddStudentView {
    
    /// أزرار التحكم في الشريط العلوي (حفظ وإلغاء)
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                saveStudent()
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
}

// MARK: - Logic & Helpers
extension AddStudentView {
    
    /// إنشاء وحفظ الطالب الجديد في قاعدة البيانات
    private func saveStudent() {
        let newStudent = Student(
                    name: name,
                    phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                    parentName: parentName.isEmpty ? nil : parentName,
                    parentPhoneNumber: parentPhoneNumber.isEmpty ? nil : parentPhoneNumber
                )
        modelContext.insert(newStudent)
        
        // محاولة الحفظ لضمان استقرار البيانات
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    AddStudentView()
        .modelContainer(for: Student.self, inMemory: true)
}
