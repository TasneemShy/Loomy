//
//  AddSessionView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct AddSessionView: View {
    // MARK: - Dependencies
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Subject.name) private var subjects: [Subject]
    @Query(sort: \Student.name) private var allStudents: [Student]
    
    // MARK: - State Properties
    @State private var selectedSubject: Subject?
    @State private var date = Date()
    @State private var hours = 1.0
    @State private var isOnline = false
    
    @State private var isShowingAddStudent = false
    @State private var selectedStudentIDs = Set<PersistentIdentifier>()
    @State private var studentDetails: [PersistentIdentifier: (rate: String, paid: String)] = [:]
    
    var preSelectedStudent: Student? = nil

    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            Form {
                sessionDetailsSection
                studentSelectionSection
                pricingSection
            }
            .navigationTitle("New Session")
            .onAppear(perform: setupInitialData)
            .sheet(isPresented: $isShowingAddStudent) { AddStudentView() }
            .toolbar { toolbarContent }
            .applyLoomyTheme()
        }
    }
}

// MARK: - Subviews
extension AddSessionView {
    
    /// القسم الأول: تفاصيل الحصة (المادة، النوع، التاريخ، الساعات)
    private var sessionDetailsSection: some View {
        Section("Session Details") {
            Picker("Subject", selection: $selectedSubject) {
                Text("Select Subject").tag(nil as Subject?)
                ForEach(subjects) { subject in
                    Text("\(subject.name) (\(subject.isUniversity ? "Uni" : "School"))")
                        .tag(subject as Subject?)
                }
            }
            .onChange(of: selectedSubject) { updateAllRates() }
            
            Toggle("Online Session", isOn: $isOnline)
                .onChange(of: isOnline) { updateAllRates() }
            
            DatePicker("Date", selection: $date, displayedComponents: .date)
            
            Stepper("Hours: \(hours, specifier: "%.1f")", value: $hours, in: 0.5...10, step: 0.5)
                .onChange(of: hours) { updateAllRates() }
        }.listRowBackground(Color.theme.surface)
    }
    
    /// القسم الثاني: اختيار الطلاب مع زر الإضافة السريعة
    private var studentSelectionSection: some View {
        Section {
            List(allStudents) { student in
                HStack {
                    Text(student.name)
                    Spacer()
                    if selectedStudentIDs.contains(student.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { toggleStudent(student) }
            }
            .onChange(of: allStudents) { updateAllRates() }
        } header: {
            HStack {
                Text("Select Students")
                Spacer()
                Button(action: { isShowingAddStudent = true }) {
                    Label("Quick Add", systemImage: "person.badge.plus")
                        .font(.caption).bold()
                }
            }
        }.listRowBackground(Color.theme.surface)
    }
    
    /// القسم الثالث: تفاصيل السعر والدفع لكل طالب مختار
    private var pricingSection: some View {
        Group {
            if !selectedStudentIDs.isEmpty {
                Section("Pricing per Student") {
                    ForEach(allStudents.filter { selectedStudentIDs.contains($0.id) }) { student in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(student.name).font(.subheadline).bold()
                            HStack {
                                TextField("Rate", text: binding(for: student.id, type: .rate))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Paid", text: binding(for: student.id, type: .paid))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }.listRowBackground(Color.theme.surface)
            }
        }
    }
    
    /// أزرار التحكم في الشريط العلوي
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") { saveSession() }
                .disabled(selectedSubject == nil || selectedStudentIDs.isEmpty)
        }
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
    }
}

// MARK: - Logic & Helpers
extension AddSessionView {
    
    private func setupInitialData() {
        if let student = preSelectedStudent {
            selectedStudentIDs.insert(student.id)
            updateAllRates()
        }
    }
    
    private func toggleStudent(_ student: Student) {
        if selectedStudentIDs.contains(student.id) {
            selectedStudentIDs.remove(student.id)
        } else {
            selectedStudentIDs.insert(student.id)
        }
        updateAllRates()
    }

    private func updateAllRates() {
        let isGroup = selectedStudentIDs.count > 1
        guard let subject = selectedSubject else { return }
        
        for id in selectedStudentIDs {
            let hourlyRate: Double
            if isOnline {
                hourlyRate = isGroup ? subject.onlineGroupRate : subject.onlineSoloRate
            } else {
                hourlyRate = isGroup ? subject.offlineGroupRate : subject.offlineSoloRate
            }
            
            let totalExpectedRate = hourlyRate * hours
            let currentPaid = studentDetails[id]?.paid ?? "0"
            
            studentDetails[id] = (rate: String(format: "%.0f", totalExpectedRate), paid: currentPaid)
        }
    }
    
    private enum DetailType { case rate, paid }
    
    private func binding(for id: PersistentIdentifier, type: DetailType) -> Binding<String> {
        Binding(
            get: {
                type == .rate ? (studentDetails[id]?.rate ?? "") : (studentDetails[id]?.paid ?? "")
            },
            set: { newValue in
                var current = studentDetails[id] ?? (rate: "0", paid: "0")
                if type == .rate { current.rate = newValue }
                else { current.paid = newValue }
                studentDetails[id] = current
            }
        )
    }

    private func saveSession() {
        let newSession = Session(date: date, hours: hours, isOnline: isOnline)
        newSession.subject = selectedSubject
        modelContext.insert(newSession)

        for studentID in selectedStudentIDs {
            if let student = allStudents.first(where: { $0.id == studentID }) {
                let details = studentDetails[studentID] ?? (rate: "0", paid: "0")
                let manualRate = Double(details.rate) ?? 0
                let amountPaid = Double(details.paid) ?? 0
                
                let attendance = Attendance(
                    student: student,
                    session: newSession,
                    agreedRate: manualRate,
                    amountPaid: amountPaid
                )
                modelContext.insert(attendance)
            }
        }
        
        try? modelContext.save()
        dismiss()
    }
}
