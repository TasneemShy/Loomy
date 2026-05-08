//
//  LoomyCalendar.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 26/04/2026.
//

import SwiftUI
import UIKit
import SwiftData

struct LoomyCalendar: UIViewRepresentable {
    @Query private var sessions: [Session]
    @Binding var selectedDate: Date
    
    // في ملف LoomyCalendar.swift
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar(identifier: .gregorian)
        
        // 1. منع التقويم من اقتراح طوله الخاص
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. إجبار الطول على رقم معين (مثلاً 300 أو 320)
        // هذا السطر هو اللي بضغط الصفوف غصب عنها
        calendarView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        
        calendarView.delegate = context.coordinator
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        calendarView.tintColor = UIColor(Color.theme.accent)
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // تحديث التقويم إذا احتجنا (SwiftUI handle)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: LoomyCalendar
        
        init(parent: LoomyCalendar) {
            self.parent = parent
        }
        
        // 1. الوظيفة اللي بتحدد وين نحط "النقطة"
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = dateComponents.date else { return nil }
            
            // فحص إذا في حصص بهذا اليوم
            let hasSession = parent.sessions.contains { session in
                Calendar.current.isDate(session.date, inSameDayAs: date)
            }
            
            if hasSession {
                // إذا في حصة، حط نقطة بلون التيفاني
                return .default(color: UIColor(Color.theme.accent), size: .medium)
            }
            
            return nil
        }
        
        // 2. تحديث التاريخ المختار لما المستخدم يكبس
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let date = dateComponents?.date {
                parent.selectedDate = date
            }
        }
    }
}
