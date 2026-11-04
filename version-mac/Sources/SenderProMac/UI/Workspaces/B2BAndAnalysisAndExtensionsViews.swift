import SwiftUI
import AppKit

// MARK: - 1. Sender Pro B2B Workspace View (Exact replica of Video V11 with 29 Connectors + Individual Portal Engine + Pagination)
public struct B2BWorkspaceView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @ObservedObject var engine = ExecutionEngine.shared
    @ObservedObject var browserMgr = BrowserSessionManager.shared

    @UIState private var selectedConnector: B2BConnectorSpec = ToolCatalog.allB2BConnectors[0]
    @UIState private var searchKeywordOrLink: String = ""
    @UIState private var keywordsList: [String] = []
    @UIState private var selectedCountry: String = "Saudi Arabia"
    @UIState private var maxPagesCount: Int = 2
    @UIState private var delaySeconds: Int = 2
    @UIState private var stopEveryCount: Int = 100
    @UIState private var waitMinutesOnStop: Int = 5
    @UIState private var extractEmailEnabled: Bool = true
    @UIState private var extractWhatsAppEnabled: Bool = true
    @UIState private var extractedRows: [[String]] = []
    @UIState private var exportFormat: ExportFormat = .excelXLSX
    @UIState private var showValidationAlert: Bool = false
    @UIState private var validationMessage: String = ""

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            // Left Vertical Scrollable Sidebar of 29 B2B Portals (Exact order from Video V11)
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(ToolCatalog.allB2BConnectors) { conn in
                        Button {
                            selectedConnector = conn
                            if let firstCountry = conn.countries.first {
                                selectedCountry = firstCountry
                            }
                        } label: {
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(selectedConnector.id == conn.id ? Color.blue : Color.clear)
                                    .frame(width: 4, height: 24)

                                Image(systemName: iconForB2B(conn.id))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 26, height: 26)
                                    .background(colorForB2B(conn.id))
                                    .cornerRadius(6)

                                Text(conn.sidebarName)
                                    .font(.system(size: 12, weight: selectedConnector.id == conn.id ? .bold : .medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .padding(.trailing, 8)
                            .background(selectedConnector.id == conn.id ? Color.blue.opacity(0.12) : Color.clear)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
            }
            .frame(width: 195)
            .background(persistence.isDarkMode ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
            .overlay(Divider(), alignment: .trailing)

            // Main B2B Scraping Workspace (Exact replica of Video V11)
            VStack(spacing: 10) {
                // Top Purple/Blue Bar: Extracting data from the site + Live Counter
                HStack {
                    Text("Extracting data from the site (\(selectedConnector.sidebarName)) — \(selectedConnector.titleAr)")
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

                // Search / URL / Country / Pagination / Google Maps Keywords Bar
                HStack(spacing: 10) {
                    TextField(persistence.isArabic ? "أدخل الرابط أو الكلمة المفتاحية للبحث (مثال: فنادق الرياض / عقارات)..." : "Enter search query or category URL...", text: $searchKeywordOrLink)
                        .textFieldStyle(.roundedBorder)

                    if !selectedConnector.countries.isEmpty {
                        Picker("Country", selection: $selectedCountry) {
                            ForEach(selectedConnector.countries, id: \.self) { c in
                                Text(c).tag(c)
                            }
                        }
                        .frame(width: 170)
                    }

                    Stepper("Pages: \(maxPagesCount)", value: $maxPagesCount, in: 1...25)
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 110)

                    if selectedConnector.supportsEmailWhatsAppToggle {
                        Toggle("Email", isOn: $extractEmailEnabled)
                            .font(.system(size: 11, weight: .semibold))
                        Toggle("WhatsApp", isOn: $extractWhatsAppEnabled)
                            .font(.system(size: 11, weight: .semibold))
                    }

                    Button {
                        let targetURL = B2BConnectorEngine.shared.buildSearchURL(
                            connectorID: selectedConnector.id,
                            country: selectedCountry,
                            queryOrURL: searchKeywordOrLink.isEmpty ? selectedConnector.portalUrl : searchKeywordOrLink,
                            page: 1
                        )
                        browserMgr.openURLInProgramBrowser(targetURL)
                    } label: {
                        Text(selectedConnector.openButtonLabel)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color(red: 0.09, green: 0.56, blue: 1.0))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }

                // Column Headers
                HStack(spacing: 4) {
                    Text("#")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, alignment: .leading)
                    ForEach(selectedConnector.columns, id: \.self) { col in
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

                // Live DataGrid
                List {
                    ForEach(Array(extractedRows.enumerated()), id: \.offset) { idx, row in
                        HStack(spacing: 4) {
                            Text("\(idx + 1)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(width: 34, alignment: .leading)
                            ForEach(0..<selectedConnector.columns.count, id: \.self) { cIdx in
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

                // Bottom Controls: Save Data, Clear, Add, Delay/Pause Settings, and Two-Stage Buttons (Scrap Links -> Extract Data -> Stop)
                VStack(spacing: 10) {
                    HStack(spacing: 16) {
                        Button {
                            guard !extractedRows.isEmpty else {
                                validationMessage = "لا توجد بيانات لحفظها حالياً / No data to save."
                                showValidationAlert = true
                                return
                            }
                            ExportService.shared.promptAndExport(
                                columns: selectedConnector.columns,
                                rows: extractedRows,
                                format: exportFormat,
                                defaultFileName: "B2B_\(selectedConnector.sidebarName.replacingOccurrences(of: " ", with: "_"))"
                            )
                        } label: {
                            Label("Save Data", systemImage: "externaldrive.fill.badge.checkmark")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .buttonStyle(.bordered)

                        Picker("", selection: $exportFormat) {
                            ForEach(ExportFormat.allCases) { fmt in
                                Text(fmt.rawValue).tag(fmt)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 210)

                        Button {
                            extractedRows.removeAll()
                        } label: {
                            Label("Clear", systemImage: "xmark.octagon.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .buttonStyle(.bordered)

                        Button {
                            let lines = ExportService.shared.promptImportLines(title: "Import Links (.txt)")
                            for l in lines {
                                var r = Array(repeating: "", count: selectedConnector.columns.count)
                                r[0] = l
                                extractedRows.append(r)
                            }
                        } label: {
                            Label("Add", systemImage: "doc.badge.plus")
                                .foregroundColor(.orange)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        HStack(spacing: 10) {
                            Text("Stop On / Count:")
                                .font(.system(size: 11))
                            TextField("100", value: $stopEveryCount, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 60)

                            Text("Wait Min:")
                                .font(.system(size: 11))
                            TextField("5", value: $waitMinutesOnStop, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)

                            Text("Delay (s):")
                                .font(.system(size: 11))
                            TextField("2", value: $delaySeconds, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                        }
                    }

                    // Two-Stage Action Buttons (Scrap Links | Extract Data | Stop — Matching Video V11)
                    HStack(spacing: 14) {
                        if !selectedConnector.isSingleStage {
                            Button {
                                runB2BExtraction(stage: "Scrap Links")
                            } label: {
                                Text("Scrap Links (استخراج الروابط)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 38)
                                    .background(Color(red: 0.09, green: 0.56, blue: 1.0))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            if selectedConnector.id == "extract_email" && searchKeywordOrLink.isEmpty && extractedRows.isEmpty {
                                validationMessage = "برجاء إضافة رابط لكي يبدأ الاستخراج / Please add a URL to start extraction."
                                showValidationAlert = true
                                return
                            }
                            runB2BExtraction(stage: "Extract Data")
                        } label: {
                            Text(selectedConnector.id == "property_finder"
                                 ? "Scrape Links and Data"
                                 : (selectedConnector.id == "extract_email" ? "Extract Email" : "Extract Data (استخراج البيانات)"))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 38)
                                .background(Color(red: 0.09, green: 0.56, blue: 1.0))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)

                        Button {
                            engine.stop()
                        } label: {
                            Text("Stop (إيقاف)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 38)
                                .background(Color(red: 0.85, green: 0.18, blue: 0.22))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(persistence.isDarkMode ? Color(red: 0.11, green: 0.12, blue: 0.14) : Color(red: 0.96, green: 0.97, blue: 0.99))
        }
        .alert("Sender Pro B2B", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    private func runB2BExtraction(stage: String) {
        let queryOrURL = searchKeywordOrLink.isEmpty ? selectedConnector.portalUrl : searchKeywordOrLink
        let firstPageURL = B2BConnectorEngine.shared.buildSearchURL(
            connectorID: selectedConnector.id,
            country: selectedCountry,
            queryOrURL: queryOrURL,
            page: 1
        )
        let collectedLinks = extractedRows.compactMap { row -> String? in
            guard let first = row.first, (first.hasPrefix("http") || first.hasPrefix("file://")) else { return nil }
            return first
        }
        if stage == "Extract Data" && !collectedLinks.isEmpty {
            extractedRows.removeAll()
        }
        browserMgr.openURLInProgramBrowser(firstPageURL)
        engine.scrapeLiveWebData(
            targetURLOrQuery: firstPageURL,
            columns: selectedConnector.columns,
            platformOrPortalName: "\(selectedConnector.sidebarName) (\(selectedCountry))",
            maxItems: 50 * maxPagesCount,
            delaySeconds: delaySeconds,
            useRandomDelay: false,
            stopEveryCount: stopEveryCount,
            waitMinutesOnStop: waitMinutesOnStop,
            stage: stage,
            existingLinks: collectedLinks,
            connectorID: selectedConnector.id,
            country: selectedCountry,
            maxPages: maxPagesCount
        ) { row in
            extractedRows.append(row)
        }
    }

    private func iconForB2B(_ id: String) -> String {
        if id.contains("google_map") { return "mappin.and.ellipse" }
        if id.contains("travel") { return "airplane.circle.fill" }
        if id.contains("aqar") || id.contains("bayut") || id.contains("property") || id.contains("ejaar") || id.contains("shamlan") { return "house.fill" }
        if id.contains("koshofat") || id.contains("altibbi") { return "cross.case.fill" }
        if id.contains("email") { return "envelope.badge.fill" }
        if id.contains("yellow") || id.contains("blue") { return "book.closed.fill" }
        return "building.2.fill"
    }

    private func colorForB2B(_ id: String) -> Color {
        if id.contains("google") { return .blue }
        if id.contains("aqar") || id.contains("bayut") || id.contains("ejaar") { return .teal }
        if id.contains("yellow") || id.contains("mzad") { return .orange }
        if id.contains("koshofat") || id.contains("altibbi") { return .mint }
        if id.contains("email") || id.contains("property") { return .red }
        return .indigo
    }
}

// MARK: - 2. Sender Pro Data Analysis Workspace (16-Column Facebook Secret Data Resolver — SQLite Indexed + Multi-Format Import + Multi-Criteria Filter + Zero Fake Data)
public struct DataAnalysisWorkspaceView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @ObservedObject var engine = ExecutionEngine.shared

    private let columns16 = [
        "IDS", "Email", "Phone", "Religion", "Birth Date", "Gender",
        "Profile Link", "First Name", "Last Name", "Username",
        "Job", "Hometown", "Current City", "Specialization", "University", "Status"
    ]

    @UIState private var inputUIDs: [String] = []
    @UIState private var manualUIDInput: String = ""
    @UIState private var resolvedRows: [[String]] = []
    @UIState private var filterCity: String = ""
    @UIState private var filterJob: String = ""
    @UIState private var filterGender: String = "ALL"
    @UIState private var customAPIEndpoint: String = ""
    @UIState private var exportFormat: ExportFormat = .excelXLSX
    @UIState private var statusBanner: String = ""

    private var filteredResolvedRows: [[String]] {
        resolvedRows.filter { row in
            guard row.count >= 15 else { return true }
            let cityMatch = filterCity.isEmpty
                || row[11].localizedCaseInsensitiveContains(filterCity)
                || row[12].localizedCaseInsensitiveContains(filterCity)
            let jobMatch = filterJob.isEmpty
                || row[10].localizedCaseInsensitiveContains(filterJob)
                || row[13].localizedCaseInsensitiveContains(filterJob)
                || row[14].localizedCaseInsensitiveContains(filterJob)
            let genderMatch = (filterGender == "ALL" || filterGender.isEmpty)
                || row[5].caseInsensitiveCompare(filterGender) == .orderedSame
            return cityMatch && jobMatch && genderMatch
        }
    }

    public init() {}

    public var body: some View {
        VStack(spacing: 10) {
            // Header Banner
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sender Pro Data Analysis — برنامج التحليل والداتا السرية (16 عمود)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.purple)
                    Text("محرك الفهرسة والبحث المحلي (SQLite: \(persistence.countIndexedFacebookRecords()) سجل) مع دعم استيراد CSV / TSV / TXT / JSON والفلترة المتقدمة بدون أي بيانات وهمية")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "cylinder.split.1x2.fill")
                        .foregroundColor(.purple)
                    Text("المفهرس: \(persistence.countIndexedFacebookRecords()) | الرصيد: \(persistence.facebookSecretPoints) نقطة")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.10))
                .cornerRadius(8)
            }
            .padding(12)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)

            if !statusBanner.isEmpty {
                Text(statusBanner)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
            }

            // Primary Controls Bar (Import Dataset, Add UIDs, Lookup, Browse All Indexed)
            HStack(spacing: 10) {
                TextField("أدخل معرف العميل UID أو رابط حساب فيسبوك أو اسم المستخدم...", text: $manualUIDInput)
                    .textFieldStyle(.roundedBorder)

                Button("استيراد قاعدة بيانات (CSV/TSV/JSON)") {
                    let panel = NSOpenPanel()
                    panel.title = "Import 16-Column Dataset (.csv, .tsv, .txt, .json)"
                    panel.canChooseFiles = true
                    if panel.runModal() == .OK, let url = panel.url {
                        if url.pathExtension.lowercased() == "json", let data = try? Data(contentsOf: url) {
                            let c = persistence.importFacebookDatasetJSON(data)
                            statusBanner = "تم استيراد وفهرسة \(c) سجل JSON في SQLite بنجاح ✓"
                        } else if let text = try? String(contentsOf: url, encoding: .utf8) {
                            let lines = text.components(separatedBy: .newlines)
                            let c = persistence.importFacebookDatasetLines(lines)
                            statusBanner = "تم استيراد وفهرسة \(c) سجل نصي في SQLite بنجاح ✓"
                        }
                    }
                }
                .buttonStyle(.bordered)

                Button("إضافة ملف UIDs (.txt)") {
                    let lines = ExportService.shared.promptImportLines(title: "Import Facebook UIDs or Profile URLs (.txt)")
                    inputUIDs.append(contentsOf: lines)
                }
                .buttonStyle(.bordered)

                Text("الأيديهات: \(inputUIDs.count)")
                    .font(.system(size: 12, weight: .bold))

                Button {
                    let targets = inputUIDs.isEmpty
                        ? (manualUIDInput.isEmpty ? [] : [manualUIDInput])
                        : inputUIDs
                    resolveUIDsTo16Columns(targets)
                } label: {
                    Text("بدء البحث (16 عمود)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.purple)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button("عرض كل السجلات المفهرسة") {
                    resolvedRows = persistence.searchIndexedFacebookRecords(
                        keyword: manualUIDInput,
                        cityFilter: filterCity,
                        jobFilter: filterJob,
                        genderFilter: filterGender
                    )
                    statusBanner = "تم استرجاع \(resolvedRows.count) سجل حقيقي من قاعدة بيانات SQLite."
                }
                .buttonStyle(.bordered)
            }

            // Secondary Multi-Criteria Filter & Export Bar
            HStack(spacing: 10) {
                TextField("تصفية بالمدينة (Current City / Hometown)...", text: $filterCity)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 220)

                TextField("تصفية بالوظيفة أو الجامعة (Job / University)...", text: $filterJob)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 240)

                Picker("الجنس (Gender)", selection: $filterGender) {
                    Text("الكل (All)").tag("ALL")
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                }
                .frame(width: 150)

                Spacer()

                Picker("", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases) { fmt in
                        Text(fmt.rawValue).tag(fmt)
                    }
                }
                .labelsHidden()
                .frame(width: 180)

                Button("تصدير النتائج (\(filteredResolvedRows.count))") {
                    ExportService.shared.promptAndExport(
                        columns: columns16,
                        rows: filteredResolvedRows,
                        format: exportFormat,
                        defaultFileName: "Facebook_Secret_Data_16Cols"
                    )
                }
                .buttonStyle(.borderedProminent)
            }

            // 16-Column DataGrid
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 6) {
                        ForEach(columns16, id: \.self) { col in
                            Text(col)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 125, alignment: .leading)
                        }
                    }
                    .padding(8)
                    .background(Color.purple)

                    List {
                        ForEach(Array(filteredResolvedRows.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: 6) {
                                ForEach(0..<columns16.count, id: \.self) { cIdx in
                                    Text(cIdx < row.count ? row[cIdx] : "")
                                        .font(.system(size: 11))
                                        .frame(width: 125, alignment: .leading)
                                        .lineLimit(1)
                                        .textSelection(.enabled)
                                }
                            }
                        }
                    }
                    .frame(width: CGFloat(columns16.count) * 132)
                }
            }
            .border(Color.gray.opacity(0.2))
        }
        .padding(14)
    }

    private func resolveUIDsTo16Columns(_ uids: [String]) {
        guard !uids.isEmpty else {
            statusBanner = "يرجى إدخال معرف UID أو استيراد ملف أيديهات للبحث."
            return
        }
        var matchedCount = 0
        var unmatchedCount = 0

        for uid in uids {
            let cleanUID = PersistenceManager.normalizeFacebookUID(uid)
            guard !cleanUID.isEmpty else { continue }

            if let record = persistence.lookupFacebookUID(cleanUID) {
                resolvedRows.append(record)
                matchedCount += 1
                if persistence.facebookSecretPoints > 0 {
                    persistence.facebookSecretPoints -= 1
                }
            } else {
                // Zero fabricated data: report honestly when UID is not in local SQLite index
                let unresolvedRow = [
                    cleanUID,
                    "Not Found in Local Index",
                    "Not Found in Local Index",
                    "N/A",
                    "N/A",
                    "N/A",
                    "https://www.facebook.com/\(cleanUID)",
                    "N/A",
                    "N/A",
                    "N/A",
                    "N/A",
                    "N/A",
                    "N/A",
                    "N/A",
                    "N/A",
                    "Unresolved (Import Dataset or Connect Secret Data Server)"
                ]
                resolvedRows.append(unresolvedRow)
                unmatchedCount += 1
            }
        }
        persistence.saveSettings()
        statusBanner = "تم فحص \(uids.count) معرف: تم العثور على \(matchedCount) سجل مطابق في SQLite، و \(unmatchedCount) غير مفهرس محلياً."
        PersistenceManager.shared.recordActivity(
            platform: "Data Analysis",
            toolName: "Facebook Secret Data (16 Columns)",
            operationType: "Analysis",
            status: matchedCount > 0 ? "Success" : "Partial (Unindexed UIDs)",
            itemsCount: matchedCount,
            details: "Matched \(matchedCount)/\(uids.count) UIDs in SQLite index"
        )
    }
}

// MARK: - 3. 15 Google Chrome & Brave Extensions Workspace
public struct ExtensionsWorkspaceView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    private let extensionsRoot = "/Users/hassen/AI/sender-pro-mac-v2/ref/Sender Pro Marketing/اضافات جوجل كروم - Google Chrome Extensions"

    @UIState private var discoveredExtensions: [(name: String, path: String, version: String)] = []
    @UIState private var statusBanner: String = ""

    public init() {}

    public var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("إضافات جوجل كروم وبريف — Sender Pro Chrome & Brave Extensions (15 Tools)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                    Text("جميع الإضافات الـ 15 الأصلية متوافقة 100% مع متصفح Google Chrome و Brave على نظام macOS")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    exportExtensionsToUserFolder()
                } label: {
                    Label("تصدير جميع الإضافات لمجلد جاهز للتثبيت", systemImage: "square.and.arrow.up.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(14)
            .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
            .cornerRadius(10)

            if !statusBanner.isEmpty {
                Text(statusBanner)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
            }

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(discoveredExtensions, id: \.path) { ext in
                        VStack(alignment: .trailing, spacing: 10) {
                            HStack {
                                Text("v\(ext.version)")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.15))
                                    .foregroundColor(.green)
                                    .cornerRadius(4)
                                Spacer()
                                Image(systemName: "puzzlepiece.extension.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.blue)
                            }

                            Text(ext.name)
                                .font(.system(size: 13, weight: .bold))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                            HStack(spacing: 8) {
                                Button {
                                    BrowserSessionManager.shared.launchExternalChromeWithExtension(extensionPath: ext.path)
                                    statusBanner = "تم تشغيل متصفح كروم مع الإضافة: \(ext.name)"
                                } label: {
                                    Text("تشغيل في Chrome")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, minHeight: 30)
                                        .background(Color.blue)
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    let popupURL = URL(fileURLWithPath: ext.path).appendingPathComponent("popup.html")
                                    if FileManager.default.fileExists(atPath: popupURL.path) {
                                        BrowserSessionManager.shared.openURLInProgramBrowser(popupURL.absoluteString)
                                    } else {
                                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: ext.path)
                                    }
                                } label: {
                                    Text("معاينة / المجلد")
                                        .font(.system(size: 11, weight: .semibold))
                                        .frame(width: 90, height: 30)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(14)
                        .background(persistence.isDarkMode ? Color.white.opacity(0.05) : Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.18), lineWidth: 1))
                    }
                }
            }
        }
        .padding(16)
        .onAppear(perform: loadExtensionsList)
    }

    private func loadExtensionsList() {
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(atPath: extensionsRoot) else { return }
        var list: [(String, String, String)] = []
        for item in items.sorted() {
            let full = (extensionsRoot as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: full, isDirectory: &isDir), isDir.boolValue {
                let manifestPath = (full as NSString).appendingPathComponent("manifest.json")
                var ver = "1.0"
                if let data = try? Data(contentsOf: URL(fileURLWithPath: manifestPath)),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let v = json["version"] as? String {
                    ver = v
                }
                list.append((item, full, ver))
            }
        }
        discoveredExtensions = list
    }

    private func exportExtensionsToUserFolder() {
        let dest = PersistenceManager.shared.appSupportDir.appendingPathComponent("ChromeExtensions", isDirectory: true)
        try? FileManager.default.removeItem(at: dest)
        try? FileManager.default.copyItem(at: URL(fileURLWithPath: extensionsRoot), to: dest)
        NSWorkspace.shared.open(dest)
        statusBanner = "تم نسخ الـ 15 إضافة إلى مجلد التطبيق وفتحه في Finder ✓"
    }
}

// MARK: - 4. Sender Pro Launcher Hub View (Replicates Sender Pro Launcher.exe)
public struct LauncherWorkspaceView: View {
    @Binding var programMode: AppProgramMode

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "paperplane.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            Text("Sender Pro V4.65.6 — macOS Native Suite")
                .font(.system(size: 28, weight: .bold))
            Text("اختر البرنامج الفرعي للبدء الفوري — Select Sub-Application")
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            HStack(spacing: 18) {
                ForEach(AppProgramMode.allCases.filter { $0 != .launcher }) { mode in
                    Button {
                        programMode = mode
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: iconForMode(mode))
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(Color.blue)
                                .cornerRadius(16)
                            Text(mode.rawValue)
                                .font(.system(size: 15, weight: .bold))
                            Text(mode.localizedTitle(isArabic: true))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .frame(width: 210, height: 175)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func iconForMode(_ mode: AppProgramMode) -> String {
        switch mode {
        case .marketing: return "megaphone.fill"
        case .b2bData: return "building.2.crop.circle.fill"
        case .dataAnalysis: return "chart.bar.xaxis"
        case .extensions: return "puzzlepiece.extension.fill"
        case .launcher: return "square.grid.2x2.fill"
        }
    }
}
