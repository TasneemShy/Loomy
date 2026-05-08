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
            StudentListView() // بينادي شاشة الطلاب
                .tabItem {
                    Label("Students", systemImage: "person.2")
                }

            SubjectListView() // بينادي شاشة المواد
                .tabItem {
                    Label("Subjects", systemImage: "book")
                }
            
            Text("Sessions Coming Soon") // مؤقت للشاشة الثالثة
                .tabItem {
                    Label("Sessions", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    ContentView()
}
