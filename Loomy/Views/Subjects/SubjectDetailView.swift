//
//  SubjectDetailView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct SubjectDetailView: View {
    @Bindable var subject: Subject
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Subject Info") {
                TextField("Name", text: $subject.name)
                Toggle("University Level", isOn: $subject.isUniversity)
            }

            Section("Offline Rates (₪)") {
                HStack { Text("Solo:"); TextField("0", value: $subject.offlineSoloRate, format: .number).keyboardType(.decimalPad) }
                HStack { Text("Group:"); TextField("0", value: $subject.offlineGroupRate, format: .number).keyboardType(.decimalPad) }
            }

            Section("Online Rates (₪)") {
                HStack { Text("Solo:"); TextField("0", value: $subject.onlineSoloRate, format: .number).keyboardType(.decimalPad) }
                HStack { Text("Group:"); TextField("0", value: $subject.onlineGroupRate, format: .number).keyboardType(.decimalPad) }
            }
        }
        .navigationTitle("Edit Subject")
    }
}
#Preview {
    //SubjectDetailView(subject: <#Subject#>)
}
