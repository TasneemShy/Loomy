//
//  DashboardView.swift
//  Loomy
//
//  Created by Tasneem Sh.Y. on 25/04/2026.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    
    // MARK: - Dependencies
    @Query private var students: [Student]
    @Query private var sessions: [Session]
    @Query private var attendanceRecords: [Attendance]
    @Query private var subjects: [Subject]
    
    // ربط العملة بالإعدادات
    @AppStorage("selectedCurrency") private var selectedCurrency = Currency.ils.rawValue
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. كروت الملخص المالي
                    mainFinancialCards
                    
                    VStack(alignment: .leading) {
                        Text("Performance")
                            .font(.headline)
                            .padding(.leading, 4)
                        
                        overallPerformanceChart
                    }
                    
                    // 3. إحصائيات سريعة
                    quickStatsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color.theme.background) // لون الخلفية الجديد
        }
    }
}

// MARK: - Subviews
extension DashboardView {
    
    /// كروت المبالغ الكلية (ديون وأرباح)
    private var mainFinancialCards: some View {
        VStack(spacing: 16) {
            // السطر الأول: الحالي مقابل المتوقع
            HStack(spacing: 12) {
                heroCard(
                    title: "Current Total",
                    value: attendanceRecords.totalActualEarnings,
                    icon: "wallet.pass.fill",
                    color: .green
                )
                                            
                heroCard(
                    title: "Expected Total",
                    value: attendanceRecords.totalExpectedEarnings,
                    icon: "target",
                    color: Color.theme.secondaryText
                )
            }
            
            HStack(spacing: 12) {
                // كرت الديون
                secondaryCard(
                    title: "Total Debt",
                    value: students.totalGlobalDebt,
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
                
                // كرت الدفع المسبق
                secondaryCard(
                    title: "Advance Paid",
                    value: students.totalGlobalExtra,
                    icon: "plus.circle.fill",
                    color: .blue
                )
            }
        }
    }
    
    /// توزيع الساعات
    private var hoursBreakdownSection: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 15) {
                hourStatBox(title: "Offline", hours: students.reduce(0) { $0 + $1.offlineHours }, icon: "house.fill", color: Color.theme.offline)
                Divider()
                hourStatBox(title: "Online", hours: students.reduce(0) { $0 + $1.onlineHours }, icon: "globe", color: Color.theme.online)
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading) {
            Text("Quick Stats")
                .font(.headline)
                .padding(.leading, 4)
                .foregroundStyle(Color.theme.text) // للتأكد من اللون بالوضع الغامق
            
            VStack(spacing: 0) {
                // 1. إجمالي الطلاب
                statRow(title: "Total Students", value: "\(students.count)", icon: "person.2.fill")
                Divider().padding(.leading, 44)
                    
                // 2. إجمالي الحصص
                statRow(title: "Total Sessions", value: "\(sessions.count)", icon: "calendar")
                Divider().padding(.leading, 44)
                
                // 3.1. إجمالي الساعات الكلية
                let totalHours = students.reduce(0) { $0 + $1.totalHours }
                statRow(title: "Total Hours", value: "\(totalHours.formatted())h", icon: "clock.fill")
                Divider().padding(.leading, 44)
                
                // 3.2. تفاصيل الساعات (Online vs Offline)
                hoursBreakdownSection
                Divider().padding(.leading, 44)

                // 4. إجمالي المواد
                statRow(title: "Total Subjects", value: "\(subjects.count)", icon: "book.closed.fill")
            }
            .background(Color.theme.surface) // التعديل الصح: لون الخلفية مش النص
            .cornerRadius(12)
        }
    }
    
    private var overallPerformanceChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Chart {
                ForEach(totalPerformance) { data in
                    // استخدمنا BarMark عشان يظل الشكل فخم
                    BarMark(
                        x: .value("Month", data.label),
                        y: .value("Earnings", data.amount)
                    )
                    .foregroundStyle(Color.theme.accent.gradient) // تدرج لوني تيفاني
                    .cornerRadius(5)
                }
                // 2. خط المتوسط (اللمسة الاحترافية الحقيقية)
//                    RuleMark(
//                        y: .value("Average", calculateAverage()) // دالة بنعملها تحت
//                    )
//                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5])) // خط مقطع (Dashed)
//                    .foregroundStyle(.secondary) // لون رمادي هادئ عشان ما يغطي على الأعمدة
//                    .annotation(position: .top, alignment: .leading) {
//                        Text("Average")
//                            .font(.caption2)
//                            .foregroundStyle(.secondary)
//                    }
            }
            .frame(height: 250) // زدنا الطول شوي عشان هيبة الأداء الكلي
            .padding()
            .background(Color.theme.surface)
            .cornerRadius(16)
            // إضافة خط متوسط الأرباح (لمسة احترافية)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
    private func calculateAverage() -> Double {
        guard !totalPerformance.isEmpty else { return 0 }
        let total = totalPerformance.reduce(0) { $0 + $1.amount }
        return total / Double(totalPerformance.count)
    }
}

// MARK: - Helper Components
extension DashboardView {
    private var totalPerformance: [PerformanceData] {
        let calendar = Calendar.current
        
        // 1. تجميع كل سجلات الحضور حسب الشهر والسنة
        let groupedByMonth = Dictionary(grouping: attendanceRecords) { record in
            let date = record.session?.date ?? Date()
            let components = calendar.dateComponents([.year, .month], from: date)
            return calendar.date(from: components) ?? date
        }
        
        // 2. تحويل الجروبات لبيانات يفهمها الـ Chart
        let results = groupedByMonth.map { (date, records) in
            let monthTotal = records.reduce(0.0) { $0 + $1.amountPaid }
            let monthName = date.formatted(.dateTime.month(.abbreviated).year(.twoDigits))
            return PerformanceData(label: monthName, amount: monthTotal, date: date)
        }
            
        // 3. ترتيب الأشهر من الأقدم للأحدث عشان الـ Chart ما يطلع مخربط
        return results.sorted { $0.date < $1.date }
    }
    
    // الكرت الضخم للأرقام الرئيسية
    private func heroCard(title: String, value: Double, icon: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 8) {
            // تم ربط العملة هنا 👇
            Text("\(value, specifier: "%.0f") \(selectedCurrency)")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .minimumScaleFactor(0.5)
            
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.secondaryText) // استخدام اللون المخصص
                    .textCase(.uppercase)
            }
        }
        .padding(.vertical, 25)
        .frame(maxWidth: .infinity)
        .background(Color.theme.surface) // لون الكروت
        .cornerRadius(24)
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // الكرت الصغير للمعلومات الجانبية
    private func secondaryCard(title: String, value: Double, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.theme.secondaryText) // استخدام اللون المخصص
            }
            
            // تم ربط العملة هنا 👇
            Text("\(value, specifier: "%.0f") \(selectedCurrency)")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.theme.surface) // لون الكروت
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func hourStatBox(title: String, hours: Double, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.theme.secondaryText) // استخدام اللون المخصص
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(hours.formatted())")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                
                Text("hrs")
                    .font(.caption2)
                    .foregroundStyle(Color.theme.secondaryText) // استخدام اللون المخصص
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color.theme.surface) // التعديل الصح: خلفية مش نص
        .cornerRadius(12)
    }
    
    private func statRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(Color.theme.secondaryText) // استخدام اللون المخصص
            Text(title)
            Spacer()
            Text(value)
                .bold()
        }
        .padding()
    }
}

// MARK: - Data Structure

struct PerformanceData: Identifiable {
    let id = UUID()
    let label: String // هاد رح يكون اسم الشهر (مثلاً: Jan 2026)
    let amount: Double
    let date: Date // بنحتاجه عشان نرتب الأشهر صح كرونولوجياً
}
