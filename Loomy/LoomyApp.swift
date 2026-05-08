//
//  LoomyApp.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI
import SwiftData

@main
struct LoomyApp: App {
    @AppStorage("appTheme") private var appTheme = "System"
    
    // تحويل النص (String) لنوع بيفهمه النظام
    // تحويل النص (String) لنوع بيفهمه النظام
        private func getColorScheme() -> ColorScheme? {
            switch appTheme {
            // 1. كل الثيمات الغامقة
            case "Dark", "Berry", "Sunset", "Earth", "Slate", "Noir":
                return .dark
                
            // 2. كل الثيمات الفاتحة
            case "Light", "Nature", "Oceanic", "Creamy", "Frost", "Misty", "Naval", "Spring", "Midnight":
                return .light
                
            // 3. الافتراضي
            default:
                return nil // System (بيلحق إعدادات الجهاز)
            }
        }
   
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(getColorScheme())
        }
        .modelContainer(for: [Subject.self, Student.self, Session.self, Attendance.self])
    }
}

