//
//  SubjectDetailView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct SubjectDetailView: View {
    // MARK: - Dependencies
    @Bindable var subject: Subject
    @Environment(\.dismiss) private var dismiss

    // MARK: - Main Body
    var body: some View {
        Form {
            subjectInfoSection
            offlineRatesSection
            onlineRatesSection
        }
        .navigationTitle("Edit Subject")
        .applyLoomyTheme()
    }
}

// MARK: - Subviews
extension SubjectDetailView {
    
    /// القسم الأول: معلومات المادة الأساسية
    private var subjectInfoSection: some View {
        Section("Subject Info") {
            TextField("Name", text: $subject.name)
                .textInputAutocapitalization(.words)
            
            Toggle("University Level", isOn: $subject.isUniversity)
                .tint(.blue)
        }.listRowBackground(Color.theme.surface)
    }
    
    /// القسم الثاني: تعديل أسعار الوجاهي (Offline)
    private var offlineRatesSection: some View {
        Section("Offline Rates (₪)") {
            rateRow(label: "Solo:", value: $subject.offlineSoloRate)
            rateRow(label: "Group:", value: $subject.offlineGroupRate)
        }.listRowBackground(Color.theme.surface)
    }
    
    /// القسم الثالث: تعديل أسعار الأونلاين (Online)
    private var onlineRatesSection: some View {
        Section("Online Rates (₪)") {
            rateRow(label: "Solo:", value: $subject.onlineSoloRate)
            rateRow(label: "Group:", value: $subject.onlineGroupRate)
        }.listRowBackground(Color.theme.surface)
    }
    
    /// مكون سطر السعر الموحد (للحفاظ على التناسق البصري)
    private func rateRow(label: String, value: Binding<Double>) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.theme.secondaryText)
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}
