# Loomy

An iOS app for private tutors to manage students, sessions and earnings in one place, built with **SwiftUI**, **SwiftData** and **Swift Charts**.

I built Loomy because I tutor university students in programming, and my classes outgrew the Excel sheet I used to track them: individual and group sessions, online and in-person rates per subject, and students who pay per session, in advance or late.

<!-- Screenshots coming soon: Dashboard · Student detail · Calendar · Settings
<p align="center">
  <img src="docs/screenshots/dashboard.png" width="200" alt="Dashboard">
  <img src="docs/screenshots/student.png" width="200" alt="Student detail">
  <img src="docs/screenshots/calendar.png" width="200" alt="Sessions calendar">
  <img src="docs/screenshots/settings.png" width="200" alt="Settings">
</p>
-->

## Features

- **Students**: profiles with contact and parent details, notes, total hours (online vs in person) and a running balance showing what each student still owes or has paid in advance.
- **Subjects with flexible pricing**: each subject has four hourly rates (solo or group × online or in person). A new session fills in each student's price from the right rate × hours, and you can still adjust it per student.
- **Sessions**: one-to-one or group sessions with per-student attendance and payment, shown on a custom calendar that marks the days you taught.
- **Dashboard**: earnings and performance charts (Swift Charts), a subject breakdown, quick stats and an hours breakdown.
- **Settings**: 5 currencies (₪, $, €, £, JD), 16 color themes with light and dark variants, and an optional **Face ID lock**.
- **Private by design**: all data stays on the device (SwiftData). No account and no server.

## Architecture

```
Loomy/
├── Models/            SwiftData @Model classes: Student, Subject, Session, Attendance
├── Views/
│   ├── Students/      list, detail, add
│   ├── Sessions/      list, detail, add, LoomyCalendar
│   ├── Subjects/      list, detail, add
│   ├── Extensions-Shared/   enums, theming, shared helpers
│   ├── DashboardView, SettingsView, LockScreenView
└── LoomyApp.swift     model container, theme and Face ID gate
```

**Data model.** `Attendance` is the join between a `Student` and a `Session`, and it stores what was agreed and what was paid for that student in that session. This one record is what makes group sessions, partial payments and per-student balances work:

```
Student 1 ── * Attendance * ── 1 Session * ── 1 Subject
              agreedRate                   4 hourly rates
              amountPaid
```

- Deleting a student or a session cascades to its attendance records. Deleting a subject keeps its past sessions (`.nullify`), so your history is never lost.
- Balances, totals and hours are computed properties on the models, so the numbers on every screen come from the same logic.

## Tech stack

| | |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Charts | Swift Charts |
| Security | LocalAuthentication (Face ID) |
| Preferences | `@AppStorage` |

## Running it

Requirements: Xcode 26 and iOS 26.2 or later (Simulator or device).

```bash
git clone https://github.com/TasneemShy/Loomy.git
open Loomy/Loomy.xcodeproj
```

Choose an iPhone simulator and press **Run** (⌘R). No configuration or API keys are needed.

## Roadmap

- UI polish across all screens
- Unit tests for the balance and pricing logic
- Export reports (PDF / CSV)
- iCloud sync between devices

## Author

**Tasneem Sheikh Youssef**: [LinkedIn](https://www.linkedin.com/in/tasneem-shy) · [GitHub](https://github.com/TasneemShy)
