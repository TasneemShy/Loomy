//
//  AppEnums.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 25/04/2026.
//

import Foundation

// MARK: - Global App Settings
enum Currency: String, CaseIterable, Codable {
    case ils = "₪"
    case jod = "JD"
    case usd = "$"
    
    var name: String {
        switch self {
        case .ils: return "Shekel"
        case .jod: return "Dinar"
        case .usd: return "Dollar"
        }
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case nature = "Nature"
    case oceanic = "Oceanic"
    case creamy = "Creamy"
    case frost = "Frost"
    case berry = "Berry"
    case sunset = "Sunset"
    case earth = "Earth"
    case slate = "Slate"
    case noir = "Noir"
    case misty = "Misty"
    case naval = "Naval"
    case spring = "Spring"
    case midnight = "Midnight"
}

// MARK: - Business Logic Enums
enum PaymentMethod: String, CaseIterable, Codable {
    case cash = "Cash"
    case bank = "Bank Transfer"
    case payPal = "PayPal"
    case zainCash = "Zain Cash"
    
    var icon: String {
        switch self {
        case .cash: return "banknote"
        case .bank: return "building.columns"
        case .payPal: return "p.circle"
        case .zainCash: return "iphone"
        }
    }
}
