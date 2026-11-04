import SwiftUI
import AppKit

// MARK: - Complete Tool Execution Panel View (Covers all specialized & standard panels in V01-V10)
public struct ToolExecutionPanelView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @ObservedObject var engine = ExecutionEngine.shared
    @ObservedObject var browserMgr = BrowserSessionManager.shared

    public let tool: MarketingToolCard
    public let onBack: () -> Void
    public let onOpenBrowsers: () -> Void
    public let onOpenContent: () -> Void

    // Shared Tool State
    @UIState private var inputKeywordOrURL: String = ""
    @UIState private var secondaryInput: String = ""
    @UIState private var targetCount: Int = 50
    @UIState private var delaySeconds: Int = 5
    @UIState private var waitingSeconds: Int = 5
    @UIState private var useRandomTime: Bool = true
    @UIState private var enablePeriodicPause: Bool = false
    @UIState private var stopEveryCount: Int = 50
    @UIState private var waitMinutesOnStop: Int = 5
    @UIState private var selectedExportFormat: ExportFormat = .excelXLSX

    // DataGrid Rows & Input List
    @UIState private var inputItems: [String] = []
    @UIState private var extractedRows: [[String]] = []
    @UIState private var secondaryRows: [[String]] = [] // Used for 3-column filters or dual grids

    // Specialized States (Login, Engagement Farm, Scheduled, SMTP, Magic Editor, Text Editor, Generate, Hashtags)
    @UIState private var loginEmail: String = ""
    @UIState private var loginPassword: String = ""
    @UIState private var loginProxy: String = ""
    @UIState private var saveCredentials: Bool = true
    @UIState private var selectedReactionType: String = "Like + Comment + Share + Save Post"
    @UIState private var selectedSocialPlatform: String = "Instagram"
    @UIState private var scheduledDate: Date = Date().addingTimeInterval(3600)
    @UIState private var smtpStepCount: Int = 200
    @UIState private var smtpHost: String = "smtp.gmail.com"
    @UIState private var smtpPort: String = "587"
    @UIState private var smtpUseSSL: Bool = true
    @UIState private var smtpSendToAll: Bool = true
    @UIState private var smtpCompanyName: String = ""
    @UIState private var smtpSubject: String = ""
    @UIState private var smtpBody: String = ""
    @UIState private var smtpCustomHTML: String = ""
    @UIState private var smtpUseCustomHTML: Bool = false
    @UIState private var smtpAttachments: [String] = []
    @UIState private var smtpCcRecipients: String = ""
    @UIState private var smtpVerifyCerts: Bool = true
    @UIState private var showSMTPListSheet: Bool = false

    // Magic Editor & Text Editor States (V10 02:24 - 03:16)
    @UIState private var magicColumnIndex: Int = 1
    @UIState private var splitPartsCount: Int = 5
    @UIState private var trimStartChars: Int = 0
    @UIState private var trimEndChars: Int = 0
    @UIState private var phonePrefix: String = "+2010"
    @UIState private var phoneDigitsCount: Int = 8
    @UIState private var phoneQuantity: Int = 100
    @UIState private var phoneSequentialMode: Bool = true
    @UIState private var downloadConcurrency: Int = 3

    // Bilingual Alert Modal (Matches V01 04:28, V02 01:00, V04 00:16, V04 02:20)
    @UIState private var showAlertModal: Bool = false
    @UIState private var alertTitle: String = ""
    @UIState private var alertMessageAr: String = ""
    @UIState private var alertMessageEn: String = ""

    public var body: some View {
        VStack(spacing: 0) {
            // Sub-header bar with Back button, Tool Title, and Tutorial Video Icon
            HStack {
                Button {
                    onBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(persistence.isArabic ? "رجوع للأدوات" : "Back")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 8) {
                    Text(persistence.isArabic ? tool.titleAr : tool.titleEn)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(tool.platform.brandColor)

                    let tier = SocialAutomationEngine.shared.classifyToolCapability(tool)
                    Text(tier.rawValue)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(tier == .publicNoAuth ? Color.green.opacity(0.15) : (tier == .prohibitedOrUnavailable ? Color.red.opacity(0.15) : Color.orange.opacity(0.15)))
                        .foregroundColor(tier == .publicNoAuth ? .green : (tier == .prohibitedOrUnavailable ? .red : .orange))
                        .cornerRadius(4)
                }

                Spacer()

                Button {
                    BrowserSessionManager.shared.openURLInProgramBrowser(tool.defaultUrl)
                } label: {
                    Label(persistence.isArabic ? "فتح الموقع في متصفح البرنامج" : "Open Target in Browser", systemImage: "safari.fill")
                        .font(.system(size: 11, weight: .semibold))
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(persistence.isDarkMode ? Color(red: 0.15, green: 0.16, blue: 0.20) : Color.white)
            .overlay(Divider(), alignment: .bottom)

            // Specialized Panel Switcher
            switch tool.panelKind {
            case .loginForm:
                platformLoginPanel
            case .smtpFourStepWizard:
                smtpWizardPanel
            case .magicFileEditor:
                magicFileEditorPanel
            case .textFileSplitter:
                textEditorSplitterPanel
            case .vcfConverter:
                vcfConverterPanel
            case .phoneGenerator:
                phoneGeneratorPanel
            case .hashtagAnalyzer:
                hashtagAnalyzerPanel
            case .videoBatchDownloader:
                videoBatchDownloaderPanel
            default:
                universalTwoColumnToolPanel
            }
        }
        .alert(alertTitle, isPresented: $showAlertModal) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(alertMessageAr)\n\(alertMessageEn)")
        }
        .sheet(isPresented: $showSMTPListSheet) {
            SMTPPresetsSheetView()
        }
    }

    // MARK: - A. Platform Login Panel (Exact replica of V01 03:44, V05 03:52, V07 02:28, V09 00:00)
    private var platformLoginPanel: some View {
        HStack(spacing: 0) {
            // Left Brand Banner
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: tool.platform.iconName)
                    .font(.system(size: 54))
                    .foregroundColor(.white)
                Text("سيندر برو")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text(persistence.isArabic ? "التسويق على \(tool.platform.rawValue)" : "\(tool.platform.rawValue) Marketing")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))

                Text(tool.descAr)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text("يتم تسجيل الدخول من هنا لاستخدام بعض الأدوات وليس كل أدوات منصة \(tool.platform.rawValue)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                Spacer()
            }
            .frame(width: 280)
            .background(tool.platform.brandColor)

            // Right Login Form
            VStack(alignment: .trailing, spacing: 16) {
                Spacer()
                Text("تسجيل الدخول")
                    .font(.system(size: 26, weight: .bold))
                Text(persistence.isArabic ? tool.descAr : tool.descEn)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("البريد الإلكتروني أو اسم المستخدم")
                        .font(.system(size: 12, weight: .semibold))
                    TextField("Email or Username", text: $loginEmail)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .trailing, spacing: 6) {
                    Text("كلمة المرور")
                        .font(.system(size: 12, weight: .semibold))
                    SecureField("Password", text: $loginPassword)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    TextField("IP : Port (Optional Proxy)", text: $loginProxy)
                        .textFieldStyle(.roundedBorder)
                    Text("البروكسي")
                        .font(.system(size: 12, weight: .semibold))
                }

                Toggle("حفظ معلومات الدخول", isOn: $saveCredentials)
                    .font(.system(size: 12))

                Button {
                    guard !loginEmail.isEmpty else {
                        triggerAlert(
                            title: "تنبيه - Warning",
                            ar: "يرجى إدخال البريد الإلكتروني أو اسم المستخدم وكلمة المرور.",
                            en: "Please enter your email/username and password."
                        )
                        return
                    }
                    let rec = SocialAccountRecord(
                        platform: tool.platform.rawValue,
                        usernameOrEmail: loginEmail,
                        password: loginPassword,
                        twoFactorSecret: "",
                        proxyHostPort: loginProxy,
                        proxyUsername: "",
                        proxyPassword: "",
                        browserType: "Chrome",
                        sessionFilePath: "",
                        isConnected: true,
                        cookiesJson: "[]"
                    )
                    persistence.socialAccounts.append(rec)
                    persistence.saveAccounts()
                    browserMgr.launchProgramBrowser(
                        initialURL: tool.defaultUrl,
                        proxyHostPort: loginProxy,
                        sessionName: "\(tool.platform.rawValue): \(loginEmail)"
                    )
                } label: {
                    Text("تسجيل الدخول")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(tool.platform.brandColor)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                HStack(spacing: 12) {
                    Button("نظام حفظ الحسابات") {
                        onOpenBrowsers()
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
            }
            .padding(40)
            .frame(maxWidth: .infinity)
            .background(persistence.isDarkMode ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
        }
        .padding(24)
    }

    // MARK: - B. Universal Two-Column Sender Pro Tool Panel (Matches V01-V10 DataGrid + Controls Layout)
    private var universalTwoColumnToolPanel: some View {
        HStack(alignment: .top, spacing: 14) {
            // Left Controls Column
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .trailing, spacing: 12) {
                    // 1. Open Accounts / Browsers Card (فتح حسابات...)
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            Text(persistence.isArabic ? "فتح حسابات \(tool.platform.rawValue)" : "Open \(tool.platform.rawValue) Accounts")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        Button {
                            onOpenBrowsers()
                        } label: {
                            Text(tool.platform == .whatsapp
                                 ? (persistence.isArabic ? "فتح الواتساب ويب / فحص التسجيل" : "Open WhatsApp Web")
                                 : (persistence.isArabic ? "فتح الحسابات (\(browserMgr.instances.count))" : "Open Accounts (\(browserMgr.instances.count))"))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 34)
                                .background(Color(red: 0.09, green: 0.56, blue: 1.0))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
                    .cornerRadius(8)

                    // 2. Input / Keyword / URL / Target List Card
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(persistence.isArabic ? "إعدادات البحث أو الرابط أو قائمة العملاء" : "Target URL / Keyword / Client List")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)

                        TextField(persistence.isArabic ? "أدخل الكلمة المفتاحية أو الرابط أو المعرف..." : "Enter keyword, URL, or ID...", text: $inputKeywordOrURL)
                            .textFieldStyle(.roundedBorder)

                        if tool.panelKind == .facebookEngagementFarm || tool.panelKind == .instagramEngagementFarm {
                            Picker("نوع العملية (Engagement Type)", selection: $selectedReactionType) {
                                Text("Like + Comment + Share + Save Post").tag("Like + Comment + Share + Save Post")
                                Text("Like + Comment").tag("Like + Comment")
                                Text("Love + Comment").tag("Love + Comment")
                                Text("Comment Only").tag("Comment Only")
                                Text("Like Only").tag("Like Only")
                                Text("Bookmark Only").tag("Bookmark Only")
                                Text("Like + Bookmark + Comment + Repost").tag("Like + Bookmark + Comment + Repost")
                            }
                            .font(.system(size: 11))
                        }

                        if tool.panelKind == .twitterScheduled {
                            DatePicker("موعد النشر (Schedule):", selection: $scheduledDate)
                                .font(.system(size: 11))
                        }

                        // Mini Input List Table + Clear / Add buttons
                        HStack {
                            Button {
                                inputItems.removeAll()
                            } label: {
                                Label(persistence.isArabic ? "حذف" : "Clear", systemImage: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .buttonStyle(.bordered)

                            Text("\(inputItems.count)")
                                .font(.system(size: 12, weight: .bold))
                                .frame(maxWidth: .infinity)

                            Button {
                                let lines = ExportService.shared.promptImportLines(title: "Import Target IDs / Links / Numbers (.txt)")
                                inputItems.append(contentsOf: lines)
                                if inputKeywordOrURL.isEmpty, let first = lines.first {
                                    inputKeywordOrURL = first
                                }
                            } label: {
                                Label(persistence.isArabic ? "إضافة ملف" : "Add File", systemImage: "doc.badge.plus")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(10)
                    .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
                    .cornerRadius(8)

                    // 3. Content Manager Trigger Card (+ إضافة المحتوى النصي)
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            Text(persistence.isArabic ? "إضافة المحتوى النصي وتحديد الفاصل الزمني" : "Message Content & Timing")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                        }

                        Button {
                            onOpenContent()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "plus.bubble.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.teal)
                                Text(persistence.isArabic
                                     ? "إضافة المحتوى النصي (\(persistence.contentTemplates.filter(\.isSelected).count) محدد)"
                                     : "+ Manage Content (\(persistence.contentTemplates.filter(\.isSelected).count) selected)")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.teal.opacity(0.10))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        // Time Interval Controls (+1 / -1 stepper matching Windows red/blue buttons)
                        HStack {
                            VStack(spacing: 2) {
                                Button("+1") { delaySeconds += 1 }
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 34, height: 18)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(3)
                                    .buttonStyle(.plain)
                                Button("-1") { delaySeconds = max(0, delaySeconds - 1) }
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 34, height: 18)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(3)
                                    .buttonStyle(.plain)
                            }
                            TextField("Sec", value: $delaySeconds, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 70)
                            Spacer()
                            Text(persistence.isArabic ? "الوقت (بالثواني)" : "Interval (s)")
                                .font(.system(size: 12, weight: .semibold))
                        }

                        HStack {
                            Stepper("\(targetCount)", value: $targetCount, in: 1...10000, step: 10)
                            Spacer()
                            Text(persistence.isArabic ? "العدد المستهدف" : "Target Count")
                                .font(.system(size: 12, weight: .semibold))
                        }

                        Toggle(persistence.isArabic ? "وقت عشوائي (Random Time)" : "Random Time (Anti-Ban)", isOn: $useRandomTime)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(10)
                    .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
                    .cornerRadius(8)

                    // 4. Periodic Pause Card (إعدادات التوقف المؤقت - V01 04:44 & V02 00:00)
                    VStack(alignment: .trailing, spacing: 8) {
                        Toggle(persistence.isArabic ? "تفعيل إعدادات التوقف المؤقت (حماية الحساب)" : "Enable Periodic Pause (Anti-Ban)", isOn: $enablePeriodicPause)
                            .font(.system(size: 11, weight: .bold))

                        if enablePeriodicPause {
                            HStack {
                                TextField("50", value: $stopEveryCount, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 70)
                                Spacer()
                                Text(persistence.isArabic ? "إيقاف عند عدد (Stop On)" : "Stop Every Count")
                                    .font(.system(size: 11))
                            }
                            HStack {
                                TextField("5", value: $waitMinutesOnStop, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 70)
                                Spacer()
                                Text(persistence.isArabic ? "إيقاف لمدة بالدقائق (Wait Min)" : "Wait Duration (Min)")
                                    .font(.system(size: 11))
                            }
                        }
                    }
                    .padding(10)
                    .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
                    .cornerRadius(8)

                    // 5. Primary Action Buttons: Start, API/AI Start, Pause, Stop, Important Notes (V04 00:16, 02:16)
                    VStack(spacing: 8) {
                        Button {
                            startToolExecution()
                        } label: {
                            Text(persistence.isArabic ? "بدء (\(tool.buttonAr))" : "Start (\(tool.buttonEn))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .background(Color(red: 0.09, green: 0.56, blue: 1.0))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)

                        if tool.platform == .whatsapp || tool.platform == .instagram || tool.platform == .twitter {
                            Button {
                                startToolExecution()
                            } label: {
                                Text(persistence.isArabic ? "بدء (API / AI) الجديد ⚡" : "Start (New API / AI) ⚡")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 32)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }

                        HStack(spacing: 8) {
                            Button {
                                engine.togglePause()
                            } label: {
                                Text(engine.isPaused ? "Resume" : (persistence.isArabic ? "إيقاف مؤقت (Pause)" : "Pause"))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 34)
                                    .background(Color.indigo)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)

                            Button {
                                engine.stop()
                            } label: {
                                Text(persistence.isArabic ? "إيقاف (Stop)" : "Stop")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 34)
                                    .background(Color(red: 0.85, green: 0.18, blue: 0.22))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }

                        if tool.platform == .whatsapp && tool.subMenu == "Filter" {
                            Button {
                                triggerAlert(
                                    title: "ملاحظات هامة - Important Notes",
                                    ar: "إذا كانت لديك مشكلة في سرعة التصفية برجاء تقليل سرعة العمليات من خلال تزويد عدد الثواني في خانة الانتظار بما يتناسب مع سرعة الإنترنت لديك.",
                                    en: "If you have a problem with filtering speed, increase the Waiting Time seconds to match your internet speed."
                                )
                            } label: {
                                Label("ملاحظات هامة !", systemImage: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 32)
                                    .background(Color.orange)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(12)
            }
            .frame(width: 310)

            // Right Live DataGrid Column (Purple/Blue Header + Real-time Counter + Clear/Add/Save)
            VStack(spacing: 10) {
                // Purple/Blue DataGrid Header Bar (Exact replica of Windows #4C5BD4 header)
                HStack {
                    Text(persistence.isArabic ? "النتائج والبيانات المستخرجة / تقرير الحملة" : "Extracted Data & Live Campaign Report")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("Count / \(extractedRows.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(6)

                // Column Headers
                HStack(spacing: 4) {
                    Text("#")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, alignment: .leading)
                    ForEach(tool.columns, id: \.self) { col in
                        Text(col)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color(red: 0.30, green: 0.36, blue: 0.83))
                .cornerRadius(4)

                // Rows List
                List {
                    ForEach(Array(extractedRows.enumerated()), id: \.offset) { idx, row in
                        HStack(spacing: 4) {
                            Text("\(idx + 1)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(width: 36, alignment: .leading)
                            ForEach(0..<tool.columns.count, id: \.self) { cIdx in
                                Text(cIdx < row.count ? row[cIdx] : "")
                                    .font(.system(size: 11))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .textSelection(.enabled)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .border(Color.gray.opacity(0.2))

                // Bottom DataGrid Toolbar: Clear (X), Counters (Total / Success / Failed), Export Format, Save, Add
                HStack(spacing: 16) {
                    Button {
                        extractedRows.removeAll()
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "xmark.octagon.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            Text(persistence.isArabic ? "حذف (Clear)" : "Clear")
                                .font(.system(size: 10, weight: .semibold))
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Live Counters (0 / 0 / 0 matching Windows bottom counters)
                    HStack(spacing: 16) {
                        Text("\(engine.failedCount)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.red)
                        Text("/")
                        Text("\(engine.successCount)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.green)
                        Text("/")
                        Text("\(extractedRows.count)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)

                    Spacer()

                    Picker(persistence.isArabic ? "حفظ بواسطة" : "Save By", selection: $selectedExportFormat) {
                        ForEach(ExportFormat.allCases) { fmt in
                            Text(fmt.rawValue).tag(fmt)
                        }
                    }
                    .frame(width: 220)

                    Button {
                        guard !extractedRows.isEmpty else {
                            triggerAlert(
                                title: "تنبيه - Warning",
                                ar: "لا توجد بيانات لحفظها حالياً.",
                                en: "No data to save yet."
                            )
                            return
                        }
                        ExportService.shared.promptAndExport(
                            columns: tool.columns,
                            rows: extractedRows,
                            format: selectedExportFormat,
                            defaultFileName: "\(tool.platform.rawValue)_\(tool.id)"
                        )
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "externaldrive.fill.badge.checkmark")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                            Text(persistence.isArabic ? "حفظ (Save)" : "Save")
                                .font(.system(size: 10, weight: .semibold))
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        let lines = ExportService.shared.promptImportLines()
                        for l in lines {
                            var row = Array(repeating: "", count: tool.columns.count)
                            row[0] = l
                            if row.count > 1 { row[1] = "Imported" }
                            extractedRows.append(row)
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                            Text(persistence.isArabic ? "إضافة (Add)" : "Add")
                                .font(.system(size: 10, weight: .semibold))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 6)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(persistence.isDarkMode ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
            .cornerRadius(8)
            .padding(12)
        }
    }

    // MARK: - C. Send Emails 4-Step SMTP Wizard (Exact replica of V09 01:44 - 02:28 + Real NWConnection SMTP Client)
    private var smtpWizardPanel: some View {
        HStack(spacing: 16) {
            // Left: Step 1 (Add Your Emails) + Step 2 (Recipients) + Step 3 & 4
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Add Your Emails")
                        .font(.system(size: 12, weight: .bold))
                    Spacer()
                    Button("All Smtp List") {
                        showSMTPListSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    Label("Step 1", systemImage: "1.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.indigo)
                }

                // SMTP Accounts Table
                VStack(spacing: 0) {
                    HStack {
                        Text("Email").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Password").frame(width: 90, alignment: .leading)
                        Text("Count").frame(width: 55, alignment: .leading)
                        Text("HOST").frame(width: 120, alignment: .leading)
                        Text("PORT").frame(width: 50, alignment: .leading)
                        Text("SSL").frame(width: 40, alignment: .leading)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.indigo)

                    List {
                        ForEach(persistence.smtpAccounts) { acc in
                            HStack {
                                Text(acc.email).frame(maxWidth: .infinity, alignment: .leading)
                                Text("••••••").frame(width: 90, alignment: .leading)
                                Text("\(acc.sendLimitCount)").frame(width: 55, alignment: .leading)
                                Text(acc.smtpHost).frame(width: 120, alignment: .leading)
                                Text("\(acc.smtpPort)").frame(width: 50, alignment: .leading)
                                Text(acc.useSSL ? "1" : "0").frame(width: 40, alignment: .leading)
                            }
                            .font(.system(size: 11))
                        }
                    }
                    .frame(height: 115)
                }
                .border(Color.gray.opacity(0.25))

                HStack {
                    Toggle("Send To All (Equal Distribution)", isOn: $smtpSendToAll)
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                    Text("\(persistence.smtpAccounts.count)")
                        .font(.system(size: 12, weight: .bold))
                    Button("Clear") {
                        persistence.smtpAccounts.removeAll()
                        persistence.saveSMTPAccounts()
                    }
                    .foregroundColor(.red)
                    Button("Add (info.txt)") {
                        let lines = ExportService.shared.promptImportLines(title: "Import SMTP Accounts (email|app_password|count|host|port|1)")
                        for l in lines {
                            let parts = l.components(separatedBy: "|")
                            if parts.count >= 5 {
                                persistence.smtpAccounts.append(
                                    SMTPAccountEntry(
                                        email: parts[0],
                                        appPassword: parts[1],
                                        sendLimitCount: Int(parts[2]) ?? 200,
                                        smtpHost: parts[3],
                                        smtpPort: Int(parts[4]) ?? 587,
                                        useSSL: parts.count > 5 ? (parts[5] == "1") : true
                                    )
                                )
                            } else {
                                persistence.smtpAccounts.append(
                                    SMTPAccountEntry(email: l, appPassword: "app-password", sendLimitCount: 200, smtpHost: "smtp.gmail.com", smtpPort: 587, useSSL: true)
                                )
                            }
                        }
                        persistence.saveSMTPAccounts()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Divider()

                // Step 2 (Send Message To ?) + Step 3 (Your Message Content)
                HStack(alignment: .top, spacing: 14) {
                    // Step 2: Recipients List
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Send Message To ?")
                                .font(.system(size: 12, weight: .bold))
                            Spacer()
                            Label("Step 2", systemImage: "2.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.indigo)
                        }
                        List(inputItems, id: \.self) { email in
                            Text(email).font(.system(size: 11))
                        }
                        .border(Color.gray.opacity(0.25))

                        HStack {
                            Button("Clear") { inputItems.removeAll() }
                                .foregroundColor(.red)
                            Spacer()
                            Text("\(inputItems.count) recipients")
                                .font(.system(size: 11, weight: .bold))
                            Spacer()
                            Button("Add") {
                                let lines = ExportService.shared.promptImportLines(title: "Import Recipient Emails (.txt)")
                                inputItems.append(contentsOf: lines)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(width: 220)

                    // Step 3: Your Message Content + Custom HTML Style + Step 4 Start
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Your Message Content")
                                .font(.system(size: 12, weight: .bold))
                            Spacer()
                            Label("Step 3", systemImage: "3.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.indigo)
                        }
                        TextField("Your Company Name (Optional)", text: $smtpCompanyName)
                            .textFieldStyle(.roundedBorder)
                        TextField("Message Subject (Title)", text: $smtpSubject)
                            .textFieldStyle(.roundedBorder)
                        TextEditor(text: $smtpBody)
                            .font(.system(size: 12))
                            .frame(height: 75)
                            .border(Color.gray.opacity(0.25))

                        HStack {
                            TextField("Custom Html Style (HTML Template) (Optional)", text: $smtpCustomHTML)
                                .textFieldStyle(.roundedBorder)
                            Toggle("Use Custom Style", isOn: $smtpUseCustomHTML)
                                .font(.system(size: 11, weight: .semibold))
                        }

                        HStack(spacing: 10) {
                            TextField("CC Recipients (comma-separated, optional)", text: $smtpCcRecipients)
                                .textFieldStyle(.roundedBorder)
                            Button("📎 Attach Files (\(smtpAttachments.count))") {
                                let panel = NSOpenPanel()
                                panel.allowsMultipleSelection = true
                                panel.canChooseFiles = true
                                if panel.runModal() == .OK {
                                    smtpAttachments.append(contentsOf: panel.urls.map(\.path))
                                }
                            }
                            .buttonStyle(.bordered)
                            if !smtpAttachments.isEmpty {
                                Button("Clear 📎") { smtpAttachments.removeAll() }
                                    .foregroundColor(.red)
                            }
                            Toggle("Verify TLS Cert", isOn: $smtpVerifyCerts)
                                .font(.system(size: 11, weight: .semibold))
                        }

                        Divider()

                        HStack {
                            Text("Start And Stop")
                                .font(.system(size: 12, weight: .bold))
                            Spacer()
                            Label("Step 4", systemImage: "4.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.indigo)
                        }

                        HStack {
                            Stepper("Time / Seconds: \(delaySeconds)s", value: $delaySeconds, in: 1...300)
                                .font(.system(size: 12))
                            Spacer()
                            Button {
                                runRealSMTPCampaign()
                            } label: {
                                Text("Start Send Messages (Real TCP/TLS/STARTTLS)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)

                            if engine.isRunning {
                                Button("Stop") { engine.stop() }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red)
                            }
                        }

                        // Real SMTP Campaign Status Log
                        if !extractedRows.isEmpty {
                            List {
                                ForEach(Array(extractedRows.enumerated()), id: \.offset) { idx, row in
                                    HStack {
                                        Text("#\(idx + 1)").font(.system(size: 10, weight: .bold))
                                        Text(row.joined(separator: " | "))
                                            .font(.system(size: 11))
                                            .textSelection(.enabled)
                                    }
                                }
                            }
                            .frame(height: 90)
                            .border(Color.gray.opacity(0.2))
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private func runRealSMTPCampaign() {
        guard !persistence.smtpAccounts.isEmpty else {
            triggerAlert(title: "SMTP Validation", ar: "يرجى إضافة حساب مرسل (SMTP) واحد على الأقل في الخطوة الأولى.", en: "Please add at least one SMTP sender account in Step 1.")
            return
        }
        guard !inputItems.isEmpty else {
            triggerAlert(title: "SMTP Validation", ar: "يرجى إضافة قائمة المستلمين في الخطوة الثانية.", en: "Please add recipient emails in Step 2.")
            return
        }
        guard !smtpSubject.isEmpty else {
            triggerAlert(title: "SMTP Validation", ar: "يرجى إدخال عنوان الرسالة (Subject).", en: "Please enter the email subject.")
            return
        }

        let accounts = persistence.smtpAccounts
        let recipients = inputItems
        let ccList = smtpCcRecipients.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let subject = smtpSubject
        let plainText = smtpBody
        let htmlContent = (smtpUseCustomHTML && !smtpCustomHTML.isEmpty) ? smtpCustomHTML : (smtpBody.contains("<") ? smtpBody : nil)
        let attachments = smtpAttachments
        let verifyTLS = smtpVerifyCerts

        Task {
            for (idx, recipient) in recipients.enumerated() {
                let account = smtpSendToAll ? accounts[idx % accounts.count] : accounts[0]
                let resolvedPlain = engine.resolveDynamicMessage(
                    rawTemplate: plainText,
                    senderName: smtpCompanyName.isEmpty ? account.email : smtpCompanyName,
                    groupName: recipient
                )
                let resolvedHTML = htmlContent.map {
                    engine.resolveDynamicMessage(
                        rawTemplate: $0,
                        senderName: smtpCompanyName.isEmpty ? account.email : smtpCompanyName,
                        groupName: recipient
                    )
                }
                let res = await RealSMTPEngine.shared.sendEmailOverRealTCP(
                    account: account,
                    toRecipients: [recipient],
                    ccRecipients: ccList,
                    companyName: smtpCompanyName,
                    subject: subject,
                    plainBody: resolvedPlain,
                    htmlBody: resolvedHTML,
                    attachmentPaths: attachments,
                    verifyCertificates: verifyTLS
                )
                extractedRows.append([
                    recipient,
                    account.email,
                    res.success ? "Sent ✓ (\(res.tlsModeUsed))" : "Failed ✗ (\(res.statusCode))",
                    "\(res.serverResponse) [Att:\(res.attachmentCount)]"
                ])
                if delaySeconds > 0 && idx + 1 < recipients.count {
                    try? await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)
                }
            }
        }
    }

    // MARK: - D. Magic Editor Panel (Exact replica of V10 02:24 - Merge & Deduplicate Files)
    private var magicFileEditorPanel: some View {
        HStack(spacing: 20) {
            // Left: Merge & Distribute Files (دمج الملفات وفلترتها وإضافة العملاء)
            VStack(alignment: .trailing, spacing: 14) {
                Text("دمج الملفات وفلترتها وإضافة العملاء في ملفات بشكل كامل")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
                Text("برجاء اختيار الملف الذي يحتوي على العملاء والذي تريد إضافتهم في الملفات")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Button("تحديد مسار الملف (Source File)") {
                    let lines = ExportService.shared.promptImportLines(title: "Select Source Client File")
                    inputItems.append(contentsOf: lines)
                }
                .buttonStyle(.borderedProminent)

                Text("عدد السطور المحملة: \(inputItems.count)")
                    .font(.system(size: 12, weight: .bold))

                Button("دمج وحفظ الملف الموحد (Merge & Save)") {
                    let unique = Array(NSOrderedSet(array: inputItems)) as? [String] ?? inputItems
                    let rows = unique.map { [$0, "Merged & Deduplicated"] }
                    extractedRows = rows
                    ExportService.shared.promptAndExport(columns: ["Client Record", "Status"], rows: rows, format: .textTXT, defaultFileName: "Merged_Clients")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)

            // Right: Cross-File Deduplicator (حذف المكرر والبيانات المتشابهة من الملفات بشكل كامل)
            VStack(alignment: .trailing, spacing: 14) {
                Text("حذف المكرر والبيانات المتشابهة من الملفات بشكل كامل")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.purple)
                Text("برجاء اختيار الملفات التي تريد حذف العملاء المكررين منها")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                HStack {
                    Stepper("رقم العمود: \(magicColumnIndex)", value: $magicColumnIndex, in: 1...20)
                    Spacer()
                    Toggle("الحذف من بداية السطر", isOn: $useRandomTime)
                }

                Button("تحديد الملفات وبدء حذف المكرر") {
                    let lines = ExportService.shared.promptImportLines(title: "Select File to Deduplicate")
                    var seen = Set<String>()
                    var cleaned: [[String]] = []
                    for l in lines {
                        let key = l.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        if !seen.contains(key) {
                            seen.insert(key)
                            cleaned.append([l, "Unique ✓"])
                        }
                    }
                    extractedRows = cleaned
                    ExportService.shared.promptAndExport(columns: ["Unique Value", "State"], rows: cleaned, format: .textTXT, defaultFileName: "Deduplicated_Output")
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)
        }
        .padding(20)
    }

    // MARK: - E. Text Editor Panel (Exact replica of V10 02:36 - Equal File Splitter & Line Trimmer)
    private var textEditorSplitterPanel: some View {
        HStack(spacing: 18) {
            VStack(alignment: .trailing, spacing: 14) {
                Text("تقسيم الملف إلى ملفات بالتساوي")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)

                Stepper("عدد التقسيم: \(splitPartsCount) ملفات", value: $splitPartsCount, in: 2...100)

                Button("تقسيم العملاء (Split File Into \(splitPartsCount) Parts)") {
                    guard !inputItems.isEmpty else {
                        let loaded = ExportService.shared.promptImportLines(title: "Select File to Split")
                        inputItems = loaded
                        return
                    }
                    let panel = NSOpenPanel()
                    panel.title = "Choose Output Folder for Split Files"
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false
                    if panel.runModal() == .OK, let dir = panel.url {
                        let chunkSize = max(1, (inputItems.count + splitPartsCount - 1) / splitPartsCount)
                        var partIdx = 1
                        for start in stride(from: 0, to: inputItems.count, by: chunkSize) {
                            let end = min(start + chunkSize, inputItems.count)
                            let chunk = inputItems[start..<end].map { [$0] }
                            let fileURL = dir.appendingPathComponent("part_\(partIdx).txt")
                            _ = ExportService.shared.writeTXTWithBOM(to: fileURL, rows: chunk)
                            partIdx += 1
                        }
                        NSWorkspace.shared.open(dir)
                    }
                }
                .buttonStyle(.borderedProminent)

                Divider()

                Text("تعديل السطور (حذف من بداية أو نهاية السطر)")
                    .font(.system(size: 14, weight: .bold))
                Stepper("حذف من بداية السطر: \(trimStartChars) حرف", value: $trimStartChars, in: 0...50)
                Stepper("حذف من نهاية السطر: \(trimEndChars) حرف", value: $trimEndChars, in: 0...50)

                Button("بدء التعديل (Apply Trim)") {
                    extractedRows = inputItems.map { line in
                        var s = line
                        if trimStartChars > 0 && s.count > trimStartChars {
                            s = String(s.dropFirst(trimStartChars))
                        }
                        if trimEndChars > 0 && s.count > trimEndChars {
                            s = String(s.dropLast(trimEndChars))
                        }
                        return [line, s]
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                Spacer()
            }
            .padding(18)
            .frame(width: 340)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)

            universalTwoColumnToolPanel
        }
        .padding(12)
    }

    // MARK: - F. Text As VCF Panel (Exact replica of V10 02:48 - 03:00)
    private var vcfConverterPanel: some View {
        HStack(spacing: 18) {
            VStack(alignment: .center, spacing: 16) {
                Text("بعض الإعدادات الهامة")
                    .font(.system(size: 13, weight: .bold))
                Button {
                    BrowserSessionManager.shared.openURLInProgramBrowser("https://contacts.google.com")
                } label: {
                    Text("جهات الاتصال جوجل (Google Contacts)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button {
                    BrowserSessionManager.shared.openURLInProgramBrowser("https://myaccount.google.com")
                } label: {
                    Text("حسابي على جوجل (My Google Account)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Divider()

                Button {
                    let lines = ExportService.shared.promptImportLines(title: "Import Phone Numbers (.txt)")
                    extractedRows = lines.enumerated().map { [$1, "Client_\($0 + 1)"] }
                } label: {
                    Label("إضافة ملف أرقام (.txt)", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    guard !extractedRows.isEmpty else {
                        triggerAlert(title: "VCF Converter", ar: "يرجى إضافة ملف الأرقام أولاً.", en: "Please import phone numbers first.")
                        return
                    }
                    ExportService.shared.promptAndExport(
                        columns: ["Number", "Name"],
                        rows: extractedRows,
                        format: .vcardVCF,
                        defaultFileName: "GoogleContacts_SenderPro"
                    )
                } label: {
                    Label("حفظ كملف VCF (Save .vcf)", systemImage: "externaldrive.fill.badge.checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(Color.green)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(18)
            .frame(width: 300)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)

            universalTwoColumnToolPanel
        }
        .padding(12)
    }

    // MARK: - G. Phone Generator Panel (Exact replica of V10 03:08 — Sequential & Random Modes)
    private var phoneGeneratorPanel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 6) {
                    Text("الرقم يبدأ بـ (Prefix e.g. +2010 / +9665)")
                        .font(.system(size: 12, weight: .semibold))
                    TextField("+2010", text: $phonePrefix)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 160)
                }
                VStack(alignment: .trailing, spacing: 6) {
                    Text("عدد الأرقام التكميلية (Digits)")
                        .font(.system(size: 12, weight: .semibold))
                    Stepper("\(phoneDigitsCount)", value: $phoneDigitsCount, in: 4...12)
                        .frame(width: 110)
                }
                VStack(alignment: .trailing, spacing: 6) {
                    Text("كمية الأرقام المطلوب توليدها")
                        .font(.system(size: 12, weight: .semibold))
                    TextField("100", value: $phoneQuantity, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
                Toggle("توليد متسلسل (Sequential)", isOn: $phoneSequentialMode)
                    .font(.system(size: 12, weight: .semibold))

                Button {
                    var generated: [[String]] = []
                    let maxVal = Int(pow(10.0, Double(max(1, phoneDigitsCount)))) - 1
                    let formatSpec = "%0\(max(1, phoneDigitsCount))d"
                    for i in 0..<min(phoneQuantity, 10000) {
                        let suffixVal: Int = phoneSequentialMode ? (i % (maxVal + 1)) : Int.random(in: 0...maxVal)
                        let formattedSuffix = String(format: formatSpec, suffixVal)
                        generated.append(["\(phonePrefix)\(formattedSuffix)"])
                    }
                    extractedRows = generated
                } label: {
                    Text("بدء التوليد (Generate)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)

            universalTwoColumnToolPanel
        }
        .padding(12)
    }

    // MARK: - H. Multi-Platform Hashtag Analyzer (Exact replica of V10 03:16 - 03:36)
    private var hashtagAnalyzerPanel: some View {
        HStack(spacing: 16) {
            VStack(alignment: .trailing, spacing: 14) {
                Text("إعدادات البحث عن الهاشتاج")
                    .font(.system(size: 13, weight: .bold))
                Picker("المنصة (Platform)", selection: $selectedSocialPlatform) {
                    Text("Instagram").tag("Instagram")
                    Text("X (Twitter)").tag("X (Twitter)")
                    Text("TikTok").tag("TikTok")
                    Text("YouTube").tag("YouTube")
                    Text("Facebook").tag("Facebook")
                }
                TextField("الكلمة المفتاحية أو رابط الصفحة...", text: $inputKeywordOrURL)
                    .textFieldStyle(.roundedBorder)

                Button {
                    let kw = inputKeywordOrURL.trimmingCharacters(in: .whitespacesAndNewlines)
                    if kw.hasPrefix("http") {
                        startToolExecution()
                    } else {
                        let base = kw.isEmpty ? "marketing" : kw.replacingOccurrences(of: " ", with: "_")
                        let suffixes = ["", "_pro", "_2026", "_arab", "_ksa", "_uae", "_egypt", "_business", "_trends", "_top", "_viral", "_deals", "_online", "_digital", "_official"]
                        extractedRows = suffixes.map { suf in
                            ["#\(base)\(suf)", "\(selectedSocialPlatform) — Keyword Expansion"]
                        }
                    }
                } label: {
                    Text("بدء البحث")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(18)
            .frame(width: 280)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)

            universalTwoColumnToolPanel
        }
        .padding(12)
    }

    // MARK: - I. Video & Media Batch Downloader Panel (ot_download — Real Concurrent HTTP Downloader)
    private var videoBatchDownloaderPanel: some View {
        HStack(spacing: 16) {
            VStack(alignment: .trailing, spacing: 14) {
                Text("تحميل الفيديوهات والملفات المباشرة")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)

                TextField("أدخل رابط الملف أو الفيديو المباشر (https://...)", text: $inputKeywordOrURL)
                    .textFieldStyle(.roundedBorder)

                Button("إضافة قائمة روابط من ملف (.txt)") {
                    let lines = ExportService.shared.promptImportLines(title: "Import Direct Media / File URLs (.txt)")
                    inputItems.append(contentsOf: lines)
                }
                .buttonStyle(.bordered)

                Stepper("التحميل المتزامن: \(downloadConcurrency) ملفات", value: $downloadConcurrency, in: 1...8)
                    .font(.system(size: 12))

                Button {
                    let urls = inputItems.isEmpty ? (inputKeywordOrURL.isEmpty ? [] : [inputKeywordOrURL]) : inputItems
                    guard !urls.isEmpty else {
                        triggerAlert(title: "Downloader", ar: "يرجى إدخال رابط أو إضافة ملف روابط.", en: "Please enter a URL or import a URL list.")
                        return
                    }
                    let destDir = persistence.exportsDir.appendingPathComponent("Downloads", isDirectory: true)
                    Task {
                        await engine.downloadFilesConcurrently(
                            urls: urls,
                            destinationFolder: destDir,
                            maxConcurrency: downloadConcurrency
                        ) { urlStr, status in
                            extractedRows.append([urlStr, status])
                        }
                    }
                } label: {
                    Text("بدء التحميل الفعلي (Download Files)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(Color.green)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button("فتح مجلد التحميلات في Finder") {
                    let destDir = persistence.exportsDir.appendingPathComponent("Downloads", isDirectory: true)
                    try? FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)
                    NSWorkspace.shared.open(destDir)
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding(18)
            .frame(width: 310)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)

            universalTwoColumnToolPanel
        }
        .padding(12)
    }

    // MARK: - Execution & Validation Logic (Replicating exact Windows Alert Boxes)
    private func startToolExecution() {
        // Validate if a message content is required for Broadcast/Marketing tools
        let isSendingTool = tool.subMenu.contains("Broadcast") || tool.subMenu.contains("Marketing") || tool.subMenu.contains("Mention") || tool.subMenu.contains("Post")
        if isSendingTool && persistence.contentTemplates.filter(\.isSelected).isEmpty {
            triggerAlert(
                title: "تنبيه - Warning",
                ar: "برجاء إضافة المحتوى الذي تريد إرساله. لكي تقوم بإضافة المحتوى قم بالضغط على زر إضافة المحتوى النصي.",
                en: "Please add the content you want to send. Click on the Add Text Content button."
            )
            return
        }

        // Ensure browser is open or auto-launch it on the target URL
        if browserMgr.instances.isEmpty {
            browserMgr.launchProgramBrowser(initialURL: inputKeywordOrURL.hasPrefix("http") ? inputKeywordOrURL : tool.defaultUrl)
        } else if inputKeywordOrURL.hasPrefix("http") {
            browserMgr.openURLInProgramBrowser(inputKeywordOrURL)
        }

        let query = inputKeywordOrURL.isEmpty ? (inputItems.first ?? tool.defaultUrl) : inputKeywordOrURL
        engine.scrapeLiveWebData(
            targetURLOrQuery: query,
            columns: tool.columns,
            platformOrPortalName: tool.platform.rawValue,
            maxItems: targetCount,
            delaySeconds: delaySeconds,
            useRandomDelay: useRandomTime,
            stopEveryCount: enablePeriodicPause ? stopEveryCount : 0,
            waitMinutesOnStop: enablePeriodicPause ? waitMinutesOnStop : 0,
            stage: "Extract Data",
            existingLinks: inputItems.filter { $0.hasPrefix("http") }
        ) { newRow in
            extractedRows.append(newRow)
        }
    }

    private func triggerAlert(title: String, ar: String, en: String) {
        alertTitle = title
        alertMessageAr = ar
        alertMessageEn = en
        showAlertModal = true
    }
}

// MARK: - Official SMTP / POP3 Servers Reference Modal (Exact replica of V09 02:04 - 02:12)
public struct SMTPPresetsSheetView: View {
    @Environment(\.dismiss) var dismiss

    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("A List of SMTP and POP3 Servers — قائمة سيرفرات البريد الإلكتروني")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            List(ToolCatalog.smtpServerPresets) { preset in
                HStack {
                    Text(preset.provider)
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 170, alignment: .leading)
                    Text("SMTP: \(preset.smtpHost)")
                        .font(.system(size: 12))
                        .frame(width: 220, alignment: .leading)
                    Text("SSL: \(preset.smtpPortSSL) | TLS: \(preset.smtpPortTLS)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(width: 160, alignment: .leading)
                    Text("POP3: \(preset.pop3Host) (\(preset.pop3PortSSL))")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(18)
        .frame(width: 780, height: 480)
    }
}
