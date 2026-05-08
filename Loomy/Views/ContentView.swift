//
//  ContentView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 23/04/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // 1. الشاشة الجديدة (الداشبورد)
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }

            // 2. شاشة الطلاب
            StudentListView()
                .tabItem {
                    Label("Students", systemImage: "person.2")
                }

            // 3. شاشة الحصص
            SessionsListView()
                .tabItem {
                    Label("Sessions", systemImage: "calendar")
                }

            // 4. شاشة المواد
            SubjectListView()
                .tabItem {
                    Label("Subjects", systemImage: "book")
                }
            
            SettingsView() // ⚙️ الإضافة الجديدة
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    ContentView()
}
