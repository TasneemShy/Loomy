//
//  AddSubjectView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct AddSubjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var offlineSolo = ""
    @State private var onlineSolo = ""
    @State private var offlineGroup = ""
    @State private var onlineGroup = ""
    @State private var isUniversity = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Subject Details") {
                    TextField("Name (e.g. C#, Calculus)", text: $name)
                }
                Section("Level") {
                    Toggle(isUniversity ? "University Level" : "School Level", isOn: $isUniversity)
                        .tint(.blue)
                }
                Section("Offline Rates (₪)") {
                    HStack { Text("Solo:"); TextField("0", text: $offlineSolo).keyboardType(.decimalPad) }
                    HStack { Text("Group:"); TextField("0", text: $offlineGroup).keyboardType(.decimalPad) }
                }

                Section("Online Rates (₪)") {
                    HStack { Text("Solo:"); TextField("0", text: $onlineSolo).keyboardType(.decimalPad) }
                    HStack { Text("Group:"); TextField("0", text: $onlineGroup).keyboardType(.decimalPad) }
                }
            }
            .navigationTitle("New Subject")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newSubject = Subject(
                            name: name,
                            offlineSolo: Double(offlineSolo) ?? 0,
                            onlineSolo: Double(onlineSolo) ?? 0,
                            offlineGroup: Double(offlineGroup) ?? 0,
                            onlineGroup: Double(onlineGroup) ?? 0,
                            isUniversity: isUniversity
                        )
                        modelContext.insert(newSubject)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddSubjectView()
}
