////
////  AppTheme.swift
////  Loomy
////
////  Created by Tasneem Sh.Y. on 26/04/2026.
////
//
//import SwiftUI
//
//enum AppTheme: String, CaseIterable, Codable {
//    case system = "System"
//    case light = "Light"
//    case dark = "Dark"
//    case nature = "Nature"
//    case oceanic = "Oceanic"
//    case creamy = "Creamy"
//    case frost = "Frost"
//    case berry = "Berry"
//    case sunset = "Sunset"
//    case earth = "Earth"
//    case slate = "Slate"
//    case noir = "Noir"
//    case misty = "Misty"
//    case naval = "Naval"
//    case spring = "Spring"
//    case midnight = "Midnight"
//
//    // 1. تحديد مظهر التلفون (فاتح/غامق)
//    var colorScheme: ColorScheme? {
//        switch self {
//        case .system: return nil
//        case .light, .nature, .oceanic , .creamy, .frost, .berry, .sunset, .earth, .slate ,
//                .noir ,.misty , .naval , .spring, .midnight : return .light // كل الملونين خليهم فاتح مبدئياً
//        case .dark: return .dark
//        }
//    }
//
//    // 2. سحب اللون من الـ Assets
//    func color(for role: String) -> Color {
//        // إذا كان الثيم عادي، رجعي ألوان النظام
//        if self == .system || self == .light || self == .dark {
//            switch role {
//            case "Primary": return .blue
//            case "Background": return Color(UIColor.systemBackground)
//            default: return .secondary
//            }
//        }
//        // إذا ثيم ملون، اسحبي من الفولدر (مثال: "Nature/Primary")
//        return Color("\(self.rawValue)/\(role)")
//    }
//}
