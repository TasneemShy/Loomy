//
//  AppColors.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 25/04/2026.
//

import SwiftUI

// MARK: - Loomy Theme
extension Color {
    /// نقطة الوصول السريعة لكل ألوان التطبيق
    static let theme = LoomyTheme()
}

struct LoomyTheme {
    // 1. جلب الثيم الحالي من الإعدادات
    var currentTheme: AppTheme {
        let rawValue = UserDefaults.standard.string(forKey: "appTheme") ?? "System"
        return AppTheme(rawValue: rawValue) ?? .system
    }

    // 2. الميثود الذكية لجلب الاسم الصحيح للون
    private func getColor(baseName: String) -> Color {
        if currentTheme == .system || currentTheme == .light || currentTheme == .dark {
            return Color(baseName) // برجع لألوانك الأصلية الشغالة
        } else {
            return Color("\(baseName)-\(currentTheme.rawValue)") // بقرأ من الـ Assets الجديدة (مثال: BackgroundColor-Nature)
        }
    }

    // 3. ألوانك الستة (الآن صارت ديناميكية بدون ما تكسر صفحاتك)
    var accent: Color { getColor(baseName: "Accent") }
    var background: Color { getColor(baseName: "Background") }
    var primary: Color { getColor(baseName: "Primary") }
    var secondaryText: Color { getColor(baseName: "Secondary") }
    var surface: Color { getColor(baseName: "Surface") }
    var text: Color { getColor(baseName: "Text") }
    
    // 4. ألوان الحالات والماليات (تبقى ثابتة لا تتأثر بالثيمات)
    let online = Color("OnlineColor")
    let offline = Color("OfflineColor")
    let solo = Color("SoloColor")
    let group = Color("GroupColor")
    let school = Color("SchoolColor")
    let uni = Color("UniversityColor")
        
    let profit = Color.green
    let debt = Color.red
}


struct LoomyThemeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden) // إخفاء خلفية النظام (الأبيض/الرمادي)
            .background(Color.theme.background) // وضع خلفيتك الملونة
            .listRowBackground(Color.theme.surface) // تلوين السطور تلقائياً
    }
}

// إضافة اختصار لاستخدامه بسهولة
extension View {
    func applyLoomyTheme() -> some View {
        self.modifier(LoomyThemeModifier())
    }
}
