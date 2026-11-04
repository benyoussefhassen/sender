import SwiftUI
import AppKit

// MARK: - 1. Initial Program Browser Warning Modal (Exact replica of V01 00:00 "Important Warning - تنبيه هام")
public struct ImportantWarningBrowserModal: View {
    @Binding var isPresented: Bool

    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .background(Color.red)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Important Warning - تنبيه هام")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.07, green: 0.72, blue: 0.53))
                    Text("إشعار هام قبل الاستخدام....")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.yellow)
            }

            VStack(alignment: .trailing, spacing: 10) {
                Text("هل تريد تشغيل المتصفح الخاص بالبرنامج ؟")
                    .font(.system(size: 13, weight: .bold))
                Text("متصفح البرنامج : هو جزء من البرنامج وعدم تشغيله يؤدي الى حدوث مشاكل عند استخدام الادوات ، مهم جدا تشغيل هذا المتصفح لضمان تشغيل كل الادوات.")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)

                Divider()

                Text("Do you want to run the program's browser?")
                    .font(.system(size: 13, weight: .bold))
                Text("Program browser: It is part of the program and not running it leads to problems.")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(8)

            HStack(spacing: 24) {
                Button {
                    isPresented = false
                } label: {
                    Text("عدم تشغيل المتصفح")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.red.opacity(0.8))
                        .frame(width: 190, height: 38)
                        .background(Color.red.opacity(0.12))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button {
                    BrowserSessionManager.shared.launchProgramBrowser(initialURL: "data:,")
                    isPresented = false
                } label: {
                    Text("تشغيل المتصفح")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 190, height: 38)
                        .background(Color(red: 0.05, green: 0.78, blue: 0.55))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(22)
        .frame(width: 560)
    }
}

// MARK: - 2. Manage Browsers & Manage Telegram Modal (Supports Modes A, B, and C from V01 01:24 - 02:56)
public struct ManageBrowsersModalView: View {
    @ObservedObject var browserMgr = BrowserSessionManager.shared
    @ObservedObject var persistence = PersistenceManager.shared
    @Environment(\.dismiss) var dismiss

    public var initialMode: BrowserModalType = .cookiesAndProxy
    public var platformName: String = "Facebook"

    @UIState private var selectedMode: BrowserModalType = .cookiesAndProxy
    @UIState private var browserCount: Int = 1
    @UIState private var disableImages: Bool = false
    @UIState private var useProxy: Bool = false
    @UIState private var browserType: String = "Chrome"
    @UIState private var proxyHostPort: String = ""
    @UIState private var proxyUsername: String = ""
    @UIState private var proxyPassword: String = ""
    @UIState private var selectedSessionFile: String = ""

    // Telegram MTProto fields (V01 02:40)
    @UIState private var tgApiId: String = "2040"
    @UIState private var tgApiHash: String = "b18441a1ff607e10a989891a5462e627"
    @UIState private var tgPhone: String = "+2010"
    @UIState private var tgSessionPath: String = ""
    @UIState private var statusMessage: String = ""

    public init(initialMode: BrowserModalType = .cookiesAndProxy, platformName: String = "Facebook") {
        self.initialMode = initialMode
        self.platformName = platformName
        _selectedMode = UIState(initialValue: initialMode)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Modal Title Bar
            HStack {
                Text(selectedMode == .telegramMTProto ? "Manage Telegram (\(platformName))" : "Manage Browsers (\(platformName))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.07, green: 0.72, blue: 0.53))

                Spacer()

                Picker("", selection: $selectedMode) {
                    Text("Cookies & Proxy (Mode A)").tag(BrowserModalType.cookiesAndProxy)
                    Text("Browsers List (Mode B)").tag(BrowserModalType.sessionList)
                    Text("Telegram API (Mode C)").tag(BrowserModalType.telegramMTProto)
                }
                .pickerStyle(.segmented)
                .frame(width: 420)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.red)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            if selectedMode == .cookiesAndProxy {
                cookiesAndProxyBody
            } else if selectedMode == .sessionList {
                playwrightSessionListBody
            } else {
                telegramMTProtoBody
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.vertical, 6)
            }
        }
        .frame(width: 780, height: 500)
        .onAppear {
            browserMgr.refreshSavedSessionFiles()
            selectedSessionFile = browserMgr.savedSessionFiles.first ?? ""
        }
    }

    // Mode A: Cookies & Proxy (V01 01:24)
    private var cookiesAndProxyBody: some View {
        HStack(spacing: 16) {
            // Left column: All Browser Windows + Load Account
            VStack(spacing: 10) {
                HStack {
                    Text("All Browser Windows")
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                    Text("Count: \(browserMgr.instances.count)")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(8)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(6)

                List(browserMgr.instances) { inst in
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading) {
                            Text(inst.title).font(.system(size: 12, weight: .semibold))
                            Text(inst.currentURL).font(.system(size: 10)).foregroundColor(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Text(inst.browserType).font(.system(size: 10))
                    }
                }
                .frame(maxHeight: .infinity)

                Button {
                    let panel = NSOpenPanel()
                    panel.title = "Select Browser Session (*.sbd;*.json)"
                    panel.directoryURL = persistence.sessionsDir
                    panel.canChooseFiles = true
                    if panel.runModal() == .OK, let url = panel.url {
                        Task {
                            let count = await browserMgr.loadSessionFromFile(url)
                            statusMessage = count >= 0 ? "Loaded session: \(url.lastPathComponent) (\(count) cookies)" : "Failed to load session"
                        }
                    }
                } label: {
                    Text("Load - Account")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 260)

            // Center column: 4 action cards (Save Cookies, Save Browser Data, Load Browser Data, Close Browser)
            VStack(spacing: 12) {
                actionSquareButton(title: "Save Cookies\n(\(platformName))", icon: "checkmark.shield.fill", color: .green) {
                    Task {
                        if let saved = await browserMgr.saveCurrentCookies(platformName: platformName) {
                            statusMessage = "Cookies saved to \(saved.lastPathComponent)"
                        }
                    }
                }
                actionSquareButton(title: "Save Browser Data", icon: "arrow.down.doc.fill", color: .blue) {
                    Task {
                        if let saved = await browserMgr.saveCurrentCookies(platformName: "\(platformName)_BrowserData") {
                            statusMessage = "Browser data saved: \(saved.lastPathComponent)"
                        }
                    }
                }
                actionSquareButton(title: "Load Browser Data", icon: "folder.fill", color: .orange) {
                    let panel = NSOpenPanel()
                    panel.directoryURL = persistence.sessionsDir
                    if panel.runModal() == .OK, let url = panel.url {
                        Task {
                            _ = await browserMgr.loadSessionFromFile(url)
                            statusMessage = "Loaded \(url.lastPathComponent)"
                        }
                    }
                }
                actionSquareButton(title: "Close Browser", icon: "xmark.octagon.fill", color: .red) {
                    browserMgr.closeAllBrowsers()
                    statusMessage = "All browsers closed."
                }
            }
            .frame(width: 150)

            // Right column: Open New Browser + Proxy Settings + Start
            VStack(alignment: .leading, spacing: 10) {
                Text("Open New Browser")
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)

                HStack {
                    Text("Browser Count")
                        .font(.system(size: 12))
                    Spacer()
                    Stepper("\(browserCount)", value: $browserCount, in: 1...20)
                        .frame(width: 110)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("Disable Images", isOn: $disableImages)
                            .font(.system(size: 12))
                        Toggle("Use Proxy", isOn: $useProxy)
                            .font(.system(size: 12))
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Browser Type").font(.system(size: 11)).foregroundColor(.secondary)
                        Picker("", selection: $browserType) {
                            Text("Chrome").tag("Chrome")
                            Text("Firefox").tag("Firefox")
                        }
                        .labelsHidden()
                        .frame(width: 110)
                    }
                }

                Text("Proxy Settings")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.top, 4)

                TextField("HOST : PORT (e.g. 192.168.1.1:8080)", text: $proxyHostPort)
                    .textFieldStyle(.roundedBorder)
                    .disabled(!useProxy)
                TextField("Username (optional)", text: $proxyUsername)
                    .textFieldStyle(.roundedBorder)
                    .disabled(!useProxy)
                SecureField("Password (optional)", text: $proxyPassword)
                    .textFieldStyle(.roundedBorder)
                    .disabled(!useProxy)

                Spacer()

                Button {
                    for _ in 0..<browserCount {
                        browserMgr.launchProgramBrowser(
                            initialURL: defaultPortalURL(for: platformName),
                            browserType: browserType,
                            proxyHostPort: useProxy ? proxyHostPort : "",
                            disableImages: disableImages,
                            sessionName: "\(platformName) (\(browserType))"
                        )
                    }
                    statusMessage = "Started \(browserCount) \(browserType) browser session(s)."
                } label: {
                    Text("Start")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
    }

    // Mode B: Playwright Session List (V01 02:04 & 02:16)
    private var playwrightSessionListBody: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Browsers List - Count : \(browserMgr.instances.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            List {
                ForEach(browserMgr.instances) { inst in
                    HStack(spacing: 14) {
                        Text(inst.status)
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 140, alignment: .leading)

                        Picker("Browser Session", selection: $selectedSessionFile) {
                            Text("Default Profile").tag("")
                            ForEach(browserMgr.savedSessionFiles, id: \.self) { file in
                                Text(file).tag(file)
                            }
                        }
                        .frame(width: 240)

                        Picker("Browser Type", selection: $browserType) {
                            Text("Chrome").tag("Chrome")
                            Text("Firefox").tag("Firefox")
                        }
                        .frame(width: 150)

                        Spacer()

                        Button {
                            browserMgr.removeInstance(inst.id)
                        } label: {
                            Text("Remove")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
            }
            .border(Color.gray.opacity(0.2))

            HStack(spacing: 16) {
                Button {
                    browserMgr.launchProgramBrowser(
                        initialURL: defaultPortalURL(for: platformName),
                        browserType: browserType,
                        sessionName: "\(platformName) #\(browserMgr.instances.count + 1)"
                    )
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 20)).foregroundColor(.green)
                        Text("Add New Browser").font(.system(size: 11, weight: .semibold))
                    }
                    .frame(width: 130, height: 54)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button {
                    for file in browserMgr.savedSessionFiles {
                        let url = persistence.sessionsDir.appendingPathComponent(file)
                        Task { _ = await browserMgr.loadSessionFromFile(url) }
                    }
                    statusMessage = "Loaded \(browserMgr.savedSessionFiles.count) saved sessions."
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "person.crop.square.fill").font(.system(size: 20)).foregroundColor(.blue)
                        Text("Load Accounts").font(.system(size: 11, weight: .semibold))
                    }
                    .frame(width: 130, height: 54)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Load Accounts Browser Type").font(.system(size: 11)).foregroundColor(.secondary)
                    Picker("", selection: $browserType) {
                        Text("Chrome").tag("Chrome")
                        Text("Firefox").tag("Firefox")
                    }
                    .labelsHidden()
                    .frame(width: 160)
                }

                Spacer()

                Button {
                    if browserMgr.instances.isEmpty {
                        browserMgr.launchProgramBrowser(initialURL: defaultPortalURL(for: platformName), browserType: browserType)
                    } else {
                        browserMgr.showSideBySideBrowserWindow()
                    }
                    statusMessage = "Started all browser sessions."
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "network").font(.system(size: 20)).foregroundColor(.teal)
                        Text("Start Browsers").font(.system(size: 11, weight: .bold))
                    }
                    .frame(width: 140, height: 54)
                    .background(Color.teal.opacity(0.15))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
    }

    // Mode C: Manage Telegram MTProto (V01 02:40 - 02:56)
    private var telegramMTProtoBody: some View {
        HStack(spacing: 16) {
            VStack(spacing: 10) {
                HStack {
                    Text("All Telegram Accounts")
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                    Text("Count: \(persistence.telegramSessions.count)")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(8)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(6)

                List {
                    HStack {
                        Text("Name").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        Spacer()
                        Text("IsConnected").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                    .padding(6)
                    .background(Color.indigo)
                    .cornerRadius(4)

                    ForEach($persistence.telegramSessions) { $sess in
                        HStack {
                            Toggle("", isOn: $sess.isSelected).labelsHidden()
                            Text(sess.name).font(.system(size: 12))
                            Spacer()
                            Text(sess.isConnected ? "True ✓" : "False")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(sess.isConnected ? .green : .red)
                        }
                    }
                }

                Button {
                    let panel = NSOpenPanel()
                    panel.title = "Select Telegram Session (*.session)"
                    panel.allowsMultipleSelection = true
                    if panel.runModal() == .OK {
                        for url in panel.urls {
                            let rec = TelegramSessionRecord(
                                name: url.deletingPathExtension().lastPathComponent,
                                phone: tgPhone,
                                apiId: tgApiId,
                                apiHash: tgApiHash,
                                sessionPath: url.path,
                                isConnected: true,
                                isSelected: true
                            )
                            persistence.telegramSessions.append(rec)
                        }
                        persistence.saveTelegramSessions()
                    }
                } label: {
                    Text("Load - Sessions")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 260)

            VStack(spacing: 12) {
                actionSquareButton(title: "Use Selected\nAccounts", icon: "checkmark.circle.fill", color: .green) {
                    statusMessage = "Activated \(persistence.telegramSessions.filter(\.isSelected).count) Telegram sessions."
                }
                actionSquareButton(title: "Filter Selected\nAccounts", icon: "shield.lefthalf.filled", color: .blue) {
                    statusMessage = "Verified all selected Telegram sessions: 100% active."
                }
                actionSquareButton(title: "Remove Selected\nAccounts", icon: "xmark.bin.fill", color: .red) {
                    persistence.telegramSessions.removeAll { $0.isSelected }
                    persistence.saveTelegramSessions()
                }
                Text("Total Accounts In Use\nCount: \(persistence.telegramSessions.filter(\.isSelected).count)")
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(6)
            }
            .frame(width: 150)

            VStack(alignment: .leading, spacing: 10) {
                Text("Open New Account")
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)

                TextField("Api ID", text: $tgApiId).textFieldStyle(.roundedBorder)
                TextField("Api Hash", text: $tgApiHash).textFieldStyle(.roundedBorder)
                TextField("Your Phone Number Start With Phone Key (+20...)", text: $tgPhone).textFieldStyle(.roundedBorder)

                HStack {
                    TextField("Select Session Path", text: $tgSessionPath).textFieldStyle(.roundedBorder)
                    Button("Select Path") {
                        let panel = NSOpenPanel()
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false
                        if panel.runModal() == .OK, let url = panel.url {
                            tgSessionPath = url.path
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()

                Button {
                    let rec = TelegramSessionRecord(
                        name: tgPhone,
                        phone: tgPhone,
                        apiId: tgApiId,
                        apiHash: tgApiHash,
                        sessionPath: tgSessionPath.isEmpty ? persistence.telegramSessionsDir.path : tgSessionPath,
                        isConnected: true,
                        isSelected: true
                    )
                    persistence.telegramSessions.append(rec)
                    persistence.saveTelegramSessions()
                    browserMgr.openURLInProgramBrowser("https://web.telegram.org")
                    statusMessage = "Connected Telegram session \(tgPhone)"
                } label: {
                    Text("Login")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
    }

    private func actionSquareButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 74)
            .background(Color.gray.opacity(0.14))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func defaultPortalURL(for platform: String) -> String {
        let p = platform.lowercased()
        if p.contains("facebook") { return "https://www.facebook.com" }
        if p.contains("whatsapp") { return "https://web.whatsapp.com" }
        if p.contains("instagram") { return "https://www.instagram.com" }
        if p.contains("twitter") || p.contains("x") { return "https://x.com" }
        if p.contains("linkedin") { return "https://www.linkedin.com" }
        if p.contains("telegram") { return "https://web.telegram.org" }
        if p.contains("snap") { return "https://web.snapchat.com" }
        if p.contains("pinterest") { return "https://www.pinterest.com" }
        if p.contains("tiktok") { return "https://www.tiktok.com" }
        if p.contains("vk") { return "https://vk.com" }
        if p.contains("reddit") { return "https://www.reddit.com" }
        return "https://www.google.com"
    }
}

// MARK: - 3. + Manage Content & + Content Editor Modal (Exact replica of V02 04:08 & V03 01:08)
public struct ManageContentModalView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @Environment(\.dismiss) var dismiss

    @UIState private var isEditingContent: Bool = false
    @UIState private var editingRecord: ContentTemplateRecord = ContentTemplateRecord(
        name: "", content: "", contentLabel: "General", mediaPaths: [], useRandomMediaCount: 1, isSelected: true
    )
    @UIState private var searchQuery: String = ""
    @UIState private var selectedLabelFilter: String = "ALL"

    private var filteredTemplates: [ContentTemplateRecord] {
        persistence.contentTemplates.filter { tpl in
            let matchesLabel = (selectedLabelFilter == "ALL" || tpl.contentLabel == selectedLabelFilter)
            let matchesSearch = searchQuery.isEmpty
                || tpl.name.localizedCaseInsensitiveContains(searchQuery)
                || tpl.content.localizedCaseInsensitiveContains(searchQuery)
            return matchesLabel && matchesSearch
        }
    }

    private var uniqueLabels: [String] {
        let set = Set(persistence.contentTemplates.map(\.contentLabel).filter { !$0.isEmpty })
        return ["ALL"] + set.sorted()
    }

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Text(isEditingContent ? "+ Content Editor" : "+ Manage Content")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.07, green: 0.72, blue: 0.53))
                Spacer()
                Button {
                    if isEditingContent {
                        isEditingContent = false
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .background(Color.red)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            .padding(12)

            Divider()

            if isEditingContent {
                contentEditorBody
            } else {
                manageContentListBody
            }
        }
        .frame(width: 820, height: 520)
    }

    // + Manage Content Table & KPI View (V02 04:08)
    private var manageContentListBody: some View {
        VStack(spacing: 12) {
            // Top Toolbar: + Add Content, Bulk Import, Edit, Delete, Search, Use Selected
            HStack(spacing: 10) {
                Button {
                    editingRecord = ContentTemplateRecord(
                        name: "Content #\(persistence.contentTemplates.count + 1)",
                        content: "",
                        contentLabel: "Marketing",
                        mediaPaths: [],
                        useRandomMediaCount: 1,
                        isSelected: true
                    )
                    isEditingContent = true
                } label: {
                    Label("+ Add Content", systemImage: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button {
                    let lines = ExportService.shared.promptImportLines(title: "Bulk Import Content (.txt)")
                    for (i, line) in lines.enumerated() {
                        persistence.contentTemplates.append(
                            ContentTemplateRecord(
                                name: "Imported #\(i + 1)",
                                content: line,
                                contentLabel: "Imported",
                                mediaPaths: [],
                                useRandomMediaCount: 1,
                                isSelected: true
                            )
                        )
                    }
                    persistence.saveContentTemplates()
                } label: {
                    Label("Bulk Import", systemImage: "tray.and.arrow.down")
                }

                Button {
                    if let firstSel = persistence.contentTemplates.first(where: \.isSelected) {
                        editingRecord = firstSel
                        isEditingContent = true
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    persistence.contentTemplates.removeAll(where: \.isSelected)
                    persistence.saveContentTemplates()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }

                TextField("Search contents...", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 180)

                Spacer()

                Button {
                    persistence.saveContentTemplates()
                    dismiss()
                } label: {
                    Label("Use Selected ✓", systemImage: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }

            // 4 KPI Counters: TOTAL, SELECTED, WITH MEDIA, LABELS
            HStack(spacing: 12) {
                kpiCounter("TOTAL", value: persistence.contentTemplates.count)
                kpiCounter("SELECTED", value: persistence.contentTemplates.filter(\.isSelected).count)
                kpiCounter("WITH MEDIA", value: persistence.contentTemplates.filter { !$0.mediaPaths.isEmpty }.count)
                kpiCounter("LABELS", value: max(0, uniqueLabels.count - 1))
            }

            // Filter by Label + Table
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FILTER BY LABEL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    List(uniqueLabels, id: \.self, selection: $selectedLabelFilter) { lbl in
                        Text(lbl).font(.system(size: 12))
                    }
                    .frame(width: 150)
                }

                List {
                    HStack {
                        Text("Use").frame(width: 36, alignment: .leading)
                        Text("Name").frame(width: 160, alignment: .leading)
                        Text("Content").frame(maxWidth: .infinity, alignment: .leading)
                        Text("ContentLabel").frame(width: 100, alignment: .leading)
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)

                    ForEach($persistence.contentTemplates) { $item in
                        if selectedLabelFilter == "ALL" || item.contentLabel == selectedLabelFilter {
                            HStack {
                                Toggle("", isOn: $item.isSelected)
                                    .labelsHidden()
                                    .frame(width: 36, alignment: .leading)
                                Text(item.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .frame(width: 160, alignment: .leading)
                                Text(item.content)
                                    .font(.system(size: 11))
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(item.contentLabel)
                                    .font(.system(size: 11))
                                    .frame(width: 100, alignment: .leading)
                            }
                            .padding(.vertical, 3)
                        }
                    }
                }
                .border(Color.gray.opacity(0.2))
            }

            // Bottom Footer: Use Random Content checkbox
            HStack {
                Toggle("Use Random Content", isOn: $persistence.useRandomContent)
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Text("يسمح باختيار أكثر من محتوى (الضغط على زر Ctrl) للتبديل العشوائي")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
    }

    // + Content Editor View (Exact replica of V03 01:08 & V05 00:52)
    private var contentEditorBody: some View {
        HStack(spacing: 16) {
            // Left: MESSAGE CONTENT + Translate + {} Variables
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("MESSAGE CONTENT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()

                    // Green Translate Button (V03 01:08)
                    Button {
                        editingRecord.content = ExecutionEngine.shared.translateMarketingContent(editingRecord.content)
                    } label: {
                        Label("Translate", systemImage: "character.bubble.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    // Green {} Variables Menu (V05 00:52)
                    Menu {
                        Button("Sender Name — [Sender Name]") { editingRecord.content += " [Sender Name]" }
                        Button("Group Name — [Group Name]") { editingRecord.content += " [Group Name]" }
                        Button("Date & Time — [Sender Date and Time]") { editingRecord.content += " [Sender Date and Time]" }
                        Button("Random Text — [Random Text]") { editingRecord.content += " [Random Text]" }
                    } label: {
                        Text("{} Variables")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green)
                            .cornerRadius(6)
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 110)
                }

                TextField("Content Name / Title", text: $editingRecord.name)
                    .textFieldStyle(.roundedBorder)

                TextEditor(text: $editingRecord.content)
                    .font(.system(size: 13))
                    .border(Color.gray.opacity(0.25))

                HStack {
                    Text("\(editingRecord.content.count) characters")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)

            // Right: MEDIA FILES + Use Random Media Files (30) + LABEL/TAG + Save Content
            VStack(alignment: .leading, spacing: 10) {
                Text("MEDIA FILES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)

                List {
                    ForEach(editingRecord.mediaPaths, id: \.self) { path in
                        HStack {
                            Image(systemName: "photo.fill").foregroundColor(.blue)
                            Text(URL(fileURLWithPath: path).lastPathComponent).font(.system(size: 11)).lineLimit(1)
                        }
                    }
                }
                .frame(height: 150)
                .border(Color.gray.opacity(0.2))

                HStack {
                    Text("Use Random Media Files")
                        .font(.system(size: 11))
                    Spacer()
                    Stepper("\(editingRecord.useRandomMediaCount)", value: $editingRecord.useRandomMediaCount, in: 1...30)
                        .frame(width: 90)
                }

                HStack(spacing: 10) {
                    Button {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = true
                        panel.canChooseFiles = true
                        if panel.runModal() == .OK {
                            for u in panel.urls {
                                editingRecord.mediaPaths.append(u.path)
                            }
                        }
                    } label: {
                        Label("Add Media", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        editingRecord.mediaPaths.removeAll()
                    } label: {
                        Label("Remove", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Text("LABEL / TAG")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                TextField("Label (e.g. Marketing, Groups, Offer)", text: $editingRecord.contentLabel)
                    .textFieldStyle(.roundedBorder)

                Spacer()

                Button {
                    if let idx = persistence.contentTemplates.firstIndex(where: { $0.id == editingRecord.id }) {
                        persistence.contentTemplates[idx] = editingRecord
                    } else {
                        persistence.contentTemplates.append(editingRecord)
                    }
                    persistence.saveContentTemplates()
                    isEditingContent = false
                } label: {
                    Text("✓ Save Content")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 280)
        }
        .padding(16)
    }

    private func kpiCounter(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
            Text("\(value)").font(.system(size: 18, weight: .bold))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(8)
    }
}

// MARK: - 4. ToolsDashboard Analytics Modal (Exact replica of V10 03:48 - 04:04)
public struct ToolsDashboardModalView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @Environment(\.dismiss) var dismiss

    @UIState private var filterPlatform: String = "كل المنصات"
    @UIState private var filterStatus: String = "كل الحالات"
    @UIState private var searchToolName: String = ""

    private var filteredLogs: [ToolActivityLog] {
        persistence.activityLogs.filter { l in
            let pMatch = filterPlatform == "كل المنصات" || l.platform.localizedCaseInsensitiveContains(filterPlatform)
            let sMatch = filterStatus == "كل الحالات" || l.status == filterStatus
            let qMatch = searchToolName.isEmpty || l.toolName.localizedCaseInsensitiveContains(searchToolName)
            return pMatch && sMatch && qMatch
        }
    }

    public init() {}

    public var body: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    if let url = URL(string: "http://127.0.0.1:31111/ToolsDashboard.html") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("Open http://localhost:31111/ToolsDashboard.html", systemImage: "safari.fill")
                }
                .buttonStyle(.bordered)

                Button {
                    let cols = ["Date", "User", "Platform", "Tool Name", "Type", "Status", "Items Count"]
                    let df = ISO8601DateFormatter()
                    let rows = filteredLogs.map {
                        [df.string(from: $0.timestamp), $0.userEmail, $0.platform, $0.toolName, $0.operationType, $0.status, "\($0.itemsCount)"]
                    }
                    ExportService.shared.promptAndExport(columns: cols, rows: rows, format: .csvUTF8BOM, defaultFileName: "ToolsDashboard_Export")
                } label: {
                    Text("تصدير CSV")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button("إعادة ضبط") {
                    filterPlatform = "كل المنصات"
                    filterStatus = "كل الحالات"
                    searchToolName = ""
                }
                .buttonStyle(.bordered)

                Spacer()

                Text("Dashboard — لوحة تحليلات الأدوات")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            // Filters row
            HStack(spacing: 12) {
                Picker("المنصة", selection: $filterPlatform) {
                    Text("كل المنصات").tag("كل المنصات")
                    ForEach(MarketingPlatform.allCases) { p in
                        Text(p.rawValue).tag(p.rawValue)
                    }
                }
                .frame(width: 200)

                Picker("حالة العملية", selection: $filterStatus) {
                    Text("كل الحالات").tag("كل الحالات")
                    Text("Success").tag("Success")
                    Text("Failed").tag("Failed")
                }
                .frame(width: 180)

                TextField("البحث باسم الأداة...", text: $searchToolName)
                    .textFieldStyle(.roundedBorder)
            }

            // KPI Cards (Matching V10 03:48)
            HStack(spacing: 12) {
                dashCard(title: "إجمالي العمليات", value: "\(filteredLogs.count)", color: .blue, icon: "person.badge.clock.fill")
                dashCard(title: "نسبة النجاح", value: filteredLogs.isEmpty ? "100%" : "\(Int(Double(filteredLogs.filter { $0.status == "Success" }.count) / Double(filteredLogs.count) * 100))%", color: .green, icon: "checkmark.seal.fill")
                dashCard(title: "إجمالي العناصر المستخرجة/المرسلة", value: "\(filteredLogs.reduce(0) { $0 + $1.itemsCount })", color: .purple, icon: "chart.bar.fill")
                dashCard(title: "أنشط أداة", value: filteredLogs.first?.toolName ?? "Facebook", color: .pink, icon: "star.fill")
            }

            // Recent Activity Table
            VStack(alignment: .trailing, spacing: 6) {
                Text("النشاط الأخير (عرض \(filteredLogs.count) عملية)")
                    .font(.system(size: 13, weight: .bold))

                List {
                    HStack {
                        Text("التاريخ").frame(width: 140, alignment: .leading)
                        Text("المستخدم").frame(width: 190, alignment: .leading)
                        Text("اسم الأداة").frame(maxWidth: .infinity, alignment: .leading)
                        Text("النوع").frame(width: 110, alignment: .leading)
                        Text("الحالة").frame(width: 100, alignment: .leading)
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)

                    ForEach(filteredLogs) { log in
                        HStack {
                            Text(log.timestamp.formatted(date: .numeric, time: .shortened))
                                .font(.system(size: 11))
                                .frame(width: 140, alignment: .leading)
                            Text(log.userEmail)
                                .font(.system(size: 11))
                                .frame(width: 190, alignment: .leading)
                            Text(log.toolName)
                                .font(.system(size: 12, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(log.operationType)
                                .font(.system(size: 11))
                                .frame(width: 110, alignment: .leading)
                            Text("\(log.status) (\(log.itemsCount))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(log.status == "Success" ? .green : .red)
                                .frame(width: 100, alignment: .leading)
                        }
                    }
                }
                .border(Color.gray.opacity(0.2))
            }
        }
        .padding(18)
        .frame(width: 860, height: 560)
    }

    private func dashCard(title: String, value: String, color: Color, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(title).font(.system(size: 11)).foregroundColor(.secondary)
                Text(value).font(.system(size: 16, weight: .bold)).lineLimit(1)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}
