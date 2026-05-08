//
//  AddSubjectView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct AddSubjectView: View {
    // MARK: - Dependencies
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    @State private var name = ""
    @State private var offlineSolo = ""
    @State private var onlineSolo = ""
    @State private var offlineGroup = ""
    @State private var onlineGroup = ""
    @State private var isUniversity = true
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            Form {
                subjectInfoSection
                levelSection
                RatesSection
                
            }
            .navigationTitle("New Subject")
            .toolbar { toolbarContent }
            .applyLoomyTheme()
        }
    }
}

// MARK: - Subviews
extension AddSubjectView {
    
    /// القسم الأول: اسم المادة
    private var subjectInfoSection: some View {
        Section("Subject Details") {
            TextField("Name (e.g. C#, Calculus)", text: $name)
                .textInputAutocapitalization(.words)
        }.listRowBackground(Color.theme.surface)
    }
    
    /// القسم الثاني: المستوى (جامعة / مدرسة)
    private var levelSection: some View {
        Section("Level") {
            Toggle(isUniversity ? "University Level" : "School Level", isOn: $isUniversity)
                .tint(.blue)
        }.listRowBackground(Color.theme.surface)
    }
    
    /// القسم الثالث: أسعار الوجاهي والأونلاين (Side-by-Side)
    private var RatesSection: some View {
        Section {
            HStack(alignment: .top, spacing: 0) {
                // --- العمود الأيسر: Offline ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("OFFLINE")
                        .font(.caption2.bold())
                        .foregroundStyle(.brown) // تمييز لوني هادئ
                    
                    rateRow(label: "Solo", text: $offlineSolo)
                    rateRow(label: "Group", text: $offlineGroup)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // فاصل عمودي خفيف
                Divider()
                    .padding(.horizontal, 15)

                // --- العمود الأيمن: Online ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("ONLINE")
                        .font(.caption2.bold())
                        .foregroundStyle(.indigo) // تمييز لوني هادئ
                    
                    rateRow(label: "Solo", text: $onlineSolo)
                    rateRow(label: "Group", text: $onlineGroup)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Hourly Rates")
        }
        .listRowBackground(Color.theme.surface)
    }

    /// مكون السطر المحدث ليناسب الأعمدة الضيقة
    private func rateRow(label: String, text: Binding<String>) -> some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.theme.secondaryText)
            
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.subheadline.bold())
            
            Text("$")
                .font(.caption2)
                .foregroundStyle(Color.theme.secondaryText)
        }
    }
    
    /// محتوى الـ Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") { saveSubject() }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
    }
}

// MARK: - Logic & Helpers
extension AddSubjectView {
    
    /// تحويل البيانات وحفظ المادة الجديدة
    private func saveSubject() {
        let newSubject = Subject(
            name: name,
            offlineSolo: Double(offlineSolo) ?? 0,
            onlineSolo: Double(onlineSolo) ?? 0,
            offlineGroup: Double(offlineGroup) ?? 0,
            onlineGroup: Double(onlineGroup) ?? 0,
            isUniversity: isUniversity
        )
        
        modelContext.insert(newSubject)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    AddSubjectView()
}
