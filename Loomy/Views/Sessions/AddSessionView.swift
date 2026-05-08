//
//  AddSessionView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

struct AddSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Subject.name) private var subjects: [Subject]
    @Query(sort: \Student.name) private var allStudents: [Student]
    
    @State private var selectedSubject: Subject?
    @State private var date = Date()
    @State private var hours = 1.0
    @State private var isOnline = false
    
    // لإدارة نافذة إضافة طالب جديد
    @State private var isShowingAddStudent = false
    
    @State private var selectedStudentIDs = Set<PersistentIdentifier>()
    @State private var studentDetails: [PersistentIdentifier: (rate: String, paid: String)] = [:]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Session Details") {
                    Picker("Subject", selection: $selectedSubject) {
                        Text("Select Subject").tag(nil as Subject?)
                        ForEach(subjects) { subject in
                            // التعديل 1: تمييز المادة في القائمة
                            Text("\(subject.name) (\(subject.isUniversity ? "Uni" : "School"))")
                                .tag(subject as Subject?)
                        }
                    }
                    .onChange(of: selectedSubject) { updateAllRates() }
                    
                    Toggle("Online Session", isOn: $isOnline)
                        .onChange(of: isOnline) { updateAllRates() }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Stepper("Hours: \(hours, specifier: "%.1f")", value: $hours, in: 0.5...10, step: 0.5)
                        .onChange(of: hours) {
                            updateAllRates() // تحديث المبالغ فور تغيير عدد الساعات
                        }
                }
                
                Section {
                    List(allStudents) { student in
                        HStack {
                            Text(student.name)
                            Spacer()
                            if selectedStudentIDs.contains(student.id) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                                
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { toggleStudent(student) }
                    }
                    .onChange(of: allStudents) {
                        updateAllRates()
                    }
                } header: {
                    HStack {
                        Text("Select Students")
                        Spacer()
                        // التعديل 2: زر إضافة طالب جديد من داخل الحصة
                        Button(action: { isShowingAddStudent = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "person.badge.plus")
                                Text("Quick Add")
                            }
                            .font(.caption).bold()
                        }
                    }
                }
                
                // ... بقية الأقسام (Pricing per Student) كما هي في الكود السابق ...
                if !selectedStudentIDs.isEmpty {
                    Section("Pricing per Student") {
                        ForEach(allStudents.filter { selectedStudentIDs.contains($0.id) }) { student in
                            VStack(alignment: .leading) {
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
                        }
                    }
                }
            }
            .navigationTitle("New Session")
            .sheet(isPresented: $isShowingAddStudent) {
                // استدعاء شاشة إضافة الطالب
                AddStudentView()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveSession() }
                        .disabled(selectedSubject == nil || selectedStudentIDs.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    // الدوال المساعدة (toggleStudent, updateAllRates, binding, saveSession)
    // تبقى كما هي في الكود السابق...
    
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
            let hourlyRate: Double // سعر الساعة الواحدة
            
            if isOnline {
                hourlyRate = isGroup ? subject.onlineGroupRate : subject.onlineSoloRate
            } else {
                hourlyRate = isGroup ? subject.offlineGroupRate : subject.offlineSoloRate
            }
            
            // الحسبة الجديدة: سعر الساعة × عدد الساعات
            let totalExpectedRate = hourlyRate * hours
            
            let currentPaid = studentDetails[id]?.paid ?? "0"
            
            // تحديث القيمة النهائية في الحقل
            studentDetails[id] = (rate: String(format: "%.0f", totalExpectedRate), paid: currentPaid)
        }
    }
    
    private enum DetailType { case rate, paid }
    private func binding(for id: PersistentIdentifier, type: DetailType) -> Binding<String> {
        Binding(
            get: {
                if type == .rate { return studentDetails[id]?.rate ?? "" }
                else { return studentDetails[id]?.paid ?? "" }
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
        let newSession = Session(date: date, hours: hours)
        newSession.subject = selectedSubject
        modelContext.insert(newSession)
        
        for studentID in selectedStudentIDs {
            if let student = allStudents.first(where: { $0.id == studentID }) {
                let details = studentDetails[studentID] ?? (rate: "0", paid: "0")
                let attendance = Attendance(
                    agreedRate: Double(details.rate) ?? 0,
                    amountPaid: Double(details.paid) ?? 0
                )
                attendance.student = student
                attendance.session = newSession
                modelContext.insert(attendance)
            }
        }
        dismiss()
    }
}
#Preview {
    AddSessionView()
}

