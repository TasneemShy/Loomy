//
//  SettingsView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 25/04/2026.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    // MARK: - Persistent Settings (AppStorage)
    @AppStorage("selectedCurrency") private var selectedCurrency: Currency = .ils
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled = false
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            Form {
                // 1. قسم التخصيص (Preferences)
                Section("Preferences") {
                    Picker("Currency", selection: $selectedCurrency) {
                        // Loops through all your enum cases automatically
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text("\(currency.rawValue) (\(currency.name))").tag(currency)
                        }
                    }
                    
                    Picker("App Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                }
                .listRowBackground(Color.theme.surface)
                
                // 2. قسم الأمان (Security)
                Section("Security") {
                    Toggle("Enable Face ID", isOn: $isFaceIDEnabled)
                        .tint(.blue)
                        .onChange(of: isFaceIDEnabled) { oldValue, newValue in
                            // Logic goes here
                            if newValue == true {
                                verifyFaceIDToEnable()
                            }
                        }
                    
                    // View (Text) goes here, OUTSIDE the .onChange
                    if isFaceIDEnabled {
                        Text("App will require Face ID to unlock.")
                            .font(.caption2)
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }
                .listRowBackground(Color.theme.surface)
                
                // 3. قسم البيانات (Data Management)
                Section("Data Management") {
                    Button(action: exportBackup) {
                        Label("Export Data Backup", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: { /* اتركها فارغة للحماية */ }) {
                        Label("Clear All Data", systemImage: "trash")
                    }
                }
                .listRowBackground(Color.theme.surface)
                
                // 4. معلومات عن التطبيق (About)
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0").foregroundStyle(Color.theme.secondaryText)
                    }
                } header: {
                    Text("About Loomy")
                } footer: {
                    Text("Designed with ☕️ for Top Tutors.")
                }
                .listRowBackground(Color.theme.surface)
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            // .applyLoomyTheme() // uncomment this if your custom modifier is ready
        }
    }
    
    // MARK: - Logic
    func exportBackup() {
        // هنا رح نبرمج لاحقاً كيف نطلع ملف JSON فيه كل البيانات
        print("Exporting backup...")
    }
    
    // The authentication function
    func verifyFaceIDToEnable() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to enable Face ID for Loomy") { success, _ in
                DispatchQueue.main.async {
                    if !success {
                        // If they cancel or fail, flip the toggle back off!
                        isFaceIDEnabled = false
                    }
                }
            }
        } else {
            // No Face ID available on device
            isFaceIDEnabled = false
        }
    }
}
