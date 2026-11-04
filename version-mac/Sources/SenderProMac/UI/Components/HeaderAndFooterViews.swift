import SwiftUI
import AppKit

// MARK: - Top Header Bar (Exact replica of Windows V4.65.6 Header with 7 Action Icons)
public struct HeaderBarView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @Binding var programMode: AppProgramMode
    @Binding var showAnalyticsSheet: Bool
    @Binding var showAccountTimePopover: Bool
    @Binding var showSupportPopover: Bool
    @Binding var showManageBrowsersSheet: Bool
    @Binding var showManageContentSheet: Bool

    public var body: some View {
        HStack(spacing: 14) {
            // Left Title & Mode Switcher (Green title matching Windows #12B886)
            HStack(spacing: 10) {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.07, green: 0.72, blue: 0.53))

                Menu {
                    ForEach(AppProgramMode.allCases) { mode in
                        Button {
                            programMode = mode
                        } label: {
                            HStack {
                                Text(mode.localizedTitle(isArabic: persistence.isArabic))
                                if programMode == mode {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(programMode.rawValue)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.07, green: 0.72, blue: 0.53))
                        Image(systemName: "chevron.down.circle.fill")
                            .foregroundColor(Color(red: 0.07, green: 0.72, blue: 0.53))
                    }
                }
                .buttonStyle(.plain)
            }

            // Quick Mode Pills (Marketing / B2B Data / Data Analysis / Extensions)
            HStack(spacing: 6) {
                ForEach([AppProgramMode.marketing, .b2bData, .dataAnalysis, .extensions], id: \.self) { mode in
                    Button {
                        programMode = mode
                    } label: {
                        Text(shortTabTitle(mode))
                            .font(.system(size: 11, weight: programMode == mode ? .bold : .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(programMode == mode ? Color(red: 0.07, green: 0.72, blue: 0.53) : Color.gray.opacity(0.14))
                            .foregroundColor(programMode == mode ? .white : .primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            // Right 7 Action Icons Observed in Videos V01-V11
            HStack(spacing: 10) {
                // 1. Purple Analytics Icon -> ToolsDashboard (V10 03:48)
                Button {
                    showAnalyticsSheet = true
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.purple)
                        .cornerRadius(7)
                }
                .buttonStyle(.plain)
                .help(persistence.isArabic ? "لوحة التحليلات - ToolsDashboard (localhost:31111)" : "Tools Analytics Dashboard")

                // 2. Red Play Icon -> Tutorials / YouTube Channel
                Button {
                    if let url = URL(string: "https://www.youtube.com/@senderprov/videos") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.red)
                        .cornerRadius(7)
                }
                .buttonStyle(.plain)
                .help(persistence.isArabic ? "شروحات الفيديو الرسمية - Official Video Tutorials" : "Official Video Tutorials")

                // 3. Screen Recorder / Content Manager Quick Button
                Button {
                    showManageContentSheet = true
                } label: {
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.orange)
                        .cornerRadius(15)
                }
                .buttonStyle(.plain)
                .help(persistence.isArabic ? "إدارة المحتوى النصي (+ Manage Content)" : "Manage Content Templates")

                // 4. Chrome / Account Time Icon (V10 04:20 Account Time - الوقت المتبقي)
                Button {
                    showAccountTimePopover.toggle()
                } label: {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showAccountTimePopover) {
                    AccountTimePopoverView()
                }
                .help(persistence.isArabic ? "الوقت المتبقي للحساب - Account Time" : "Account Subscription Time")

                // 5. SUPPORT Icon (V01 00:32 & V10 04:28)
                Button {
                    showSupportPopover.toggle()
                } label: {
                    VStack(spacing: 1) {
                        Image(systemName: "person.wave.2.fill")
                            .font(.system(size: 12))
                        Text("SUPPORT")
                            .font(.system(size: 7, weight: .bold))
                    }
                    .foregroundColor(.teal)
                    .frame(width: 44, height: 30)
                    .background(Color.teal.opacity(0.12))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showSupportPopover) {
                    SupportCenterPopoverView()
                }
                .help(persistence.isArabic ? "الدعم الفني - Support Center" : "Support Center")

                // 6. Open Program Browser Window Button
                Button {
                    BrowserSessionManager.shared.showSideBySideBrowserWindow()
                } label: {
                    Image(systemName: "macwindow.split.2x1")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help(persistence.isArabic ? "إظهار متصفح البرنامج بجانب التطبيق" : "Show Side-by-Side Program Browser")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(persistence.isDarkMode ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
        .overlay(Divider(), alignment: .bottom)
    }

    private func shortTabTitle(_ mode: AppProgramMode) -> String {
        switch mode {
        case .marketing: return persistence.isArabic ? "برنامج التسويق (Marketing)" : "Marketing"
        case .b2bData: return persistence.isArabic ? "برنامج الداتا (B2B Data)" : "B2B Data"
        case .dataAnalysis: return persistence.isArabic ? "برنامج التحليل (Analysis)" : "Data Analysis"
        case .extensions: return persistence.isArabic ? "إضافات كروم (15)" : "Extensions (15)"
        case .launcher: return "Launcher"
        }
    }
}

// MARK: - Account Time Popover (Exact replica of V10 04:20 "Account Time - الوقت المتبقي")
public struct AccountTimePopoverView: View {
    @ObservedObject var persistence = PersistenceManager.shared

    public var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                Text("Account Time - الوقت المتبقي")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.07, green: 0.72, blue: 0.53))
                Spacer()
            }
            Divider()
            VStack(alignment: .trailing, spacing: 10) {
                accountRow(title: "برنامج التسويق | marketing", expiry: persistence.marketingExpiryDate)
                Divider()
                accountRow(title: "برنامج الداتا | data", expiry: persistence.dataExpiryDate)
                Divider()
                accountRow(title: "الدعم الفني | Support", expiry: persistence.supportExpiryDate)
                Divider()
                HStack {
                    Text("\(persistence.facebookSecretPoints) نقطة")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.blue)
                    Spacer()
                    Text("نقاط تحليل الداتا السرية | Secret Data Points")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
        }
        .padding(16)
        .frame(width: 340)
    }

    private func accountRow(title: String, expiry: String) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("الوقت المتبقي لانتهاء اشتراك :")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.blue)
            Text("ينتهي في : \(expiry)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.green)
        }
    }
}

// MARK: - Support Center Popover (Replicates SupportCenter.cs in V10 04:28)
public struct SupportCenterPopoverView: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("الدعم الفني - Sender Pro Support Center")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 0.07, green: 0.72, blue: 0.53))
            Text("مواعيد العمل الرسمية: من السبت إلى الخميس (11 صباحاً - 6 مساءً بتوقيت القاهرة)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Divider()
            Button {
                if let url = URL(string: "https://wa.me/201029042177") { NSWorkspace.shared.open(url) }
            } label: {
                Label("التواصل عبر واتساب (+201029042177)", systemImage: "phone.bubble.left.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Button {
                if let url = URL(string: "https://fb.com/senderprov4") { NSWorkspace.shared.open(url) }
            } label: {
                Label("صفحة فيسبوك الرسمية (fb.com/senderprov4)", systemImage: "hand.thumbsup.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)

            Button {
                if let url = URL(string: "https://senderprov.com/en/support/contact") { NSWorkspace.shared.open(url) }
            } label: {
                Label("الموقع الرسمي (senderprov.com)", systemImage: "globe")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .frame(width: 340)
    }
}

// MARK: - Bottom Footer Bar (Exact replica of Windows V4.65.6 Footer with Language & Theme Switches)
public struct FooterBarView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @ObservedObject var engine = ExecutionEngine.shared

    public var body: some View {
        HStack(spacing: 16) {
            Text("Copyright © 2019 -2026   Sender Pro V4.65.6")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)

            if !engine.statusBanner.isEmpty {
                HStack(spacing: 6) {
                    if engine.isRunning {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(engine.statusBanner)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(engine.isRunning ? .blue : .green)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.08))
                .cornerRadius(6)
            }

            Spacer()

            // Language Toggle: English <-> Arabic
            HStack(spacing: 6) {
                Text("English")
                    .font(.system(size: 11, weight: !persistence.isArabic ? .bold : .regular))
                Toggle("", isOn: $persistence.isArabic)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
                Text("Arabic")
                    .font(.system(size: 11, weight: persistence.isArabic ? .bold : .regular))
            }

            // Theme Toggle: Light <-> Dark
            HStack(spacing: 6) {
                Text("Light")
                    .font(.system(size: 11, weight: !persistence.isDarkMode ? .bold : .regular))
                Toggle("", isOn: $persistence.isDarkMode)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
                Text("Dark")
                    .font(.system(size: 11, weight: persistence.isDarkMode ? .bold : .regular))
            }

            HStack(spacing: 6) {
                Text("Designed by : Sender Pro")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Image(systemName: "globe.europe.africa.fill")
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(persistence.isDarkMode ? Color(red: 0.12, green: 0.13, blue: 0.16) : Color(red: 0.97, green: 0.98, blue: 0.99))
        .overlay(Divider(), alignment: .top)
    }
}
