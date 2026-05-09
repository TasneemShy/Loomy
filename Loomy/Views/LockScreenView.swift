//
//  LockScreenView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 10/05/2026.
//

import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    // This binding lets the lock screen tell the main app "We are unlocked!"
    @Binding var isUnlocked: Bool
    @State private var errorText = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Loomy is Locked")
                .font(.title2).bold()
            
            Button("Tap to Unlock") {
                authenticate()
            }
            .buttonStyle(.borderedProminent)
            
            Text(errorText)
                .foregroundColor(.red)
                .font(.caption)
        }
        // Automatically try to unlock the moment the screen appears
        .onAppear(perform: authenticate)
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Loomy Dashboard") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        // Success! This dismisses the lock screen
                        isUnlocked = true
                    } else {
                        errorText = "Face ID not recognized. Try again."
                    }
                }
            }
        }
    }
}
