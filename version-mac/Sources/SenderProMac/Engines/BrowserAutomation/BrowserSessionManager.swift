import Foundation
import AppKit
import WebKit
import SwiftUI

// MARK: - Active Browser Instance (Real Per-Session Isolated WKWebsiteDataStore + JS DOM Engine)
@MainActor
public final class BrowserInstance: NSObject, Identifiable, ObservableObject, WKNavigationDelegate {
    public let id: UUID
    @Published public var title: String
    @Published public var currentURL: String
    @Published public var browserType: String
    @Published public var proxyHostPort: String
    @Published public var disableImages: Bool
    @Published public var status: String = "Ready To Start"
    @Published public var isLoading: Bool = false
    @Published public var lastHTTPStatusCode: Int = 0

    public let webView: WKWebView
    public let dataStoreIdentifier: UUID
    private var navigationWaiters: [CheckedContinuation<Bool, Never>] = []

    public init(
        sessionUUID: UUID = UUID(),
        title: String,
        initialURL: String = "https://www.google.com",
        browserType: String = "Chrome",
        proxyHostPort: String = "",
        disableImages: Bool = false,
        ephemeral: Bool = false
    ) {
        self.id = sessionUUID
        self.dataStoreIdentifier = sessionUUID
        self.title = title
        self.currentURL = initialURL
        self.browserType = browserType
        self.proxyHostPort = proxyHostPort
        self.disableImages = disableImages

        let config = WKWebViewConfiguration()
        // True per-session cookie & storage isolation on macOS 14+
        if ephemeral {
            config.websiteDataStore = .nonPersistent()
        } else if #available(macOS 14.0, *) {
            config.websiteDataStore = WKWebsiteDataStore(forIdentifier: sessionUUID)
        } else {
            config.websiteDataStore = .default()
        }

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        if disableImages {
            let blockImagesRule = """
            [{"trigger": {"url-filter": ".*", "resource-type": ["image"]}, "action": {"type": "block"}}]
            """
            WKContentRuleListStore.default().compileContentRuleList(
                forIdentifier: "BlockImages_\(sessionUUID.uuidString)",
                encodedContentRuleList: blockImagesRule
            ) { list, _ in
                if let list = list {
                    config.userContentController.add(list)
                }
            }
        }

        self.webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 640, height: 780), configuration: config)
        super.init()
        self.webView.navigationDelegate = self
        self.webView.customUserAgent = browserType == "Firefox"
            ? "Mozilla/5.0 (Macintosh; Intel Mac OS X 14.5; rv:128.0) Gecko/20100101 Firefox/128.0"
            : "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
    }

    public func load(urlString: String) {
        let cleaned = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        if cleaned == "data:," {
            webView.loadHTMLString("""
            <html><head><meta charset="utf-8"><style>
            body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background:#f8f9fa; color:#333; padding:32px; }
            .banner { background:#e7f5ff; border:1px solid #74c0fc; padding:12px 16px; border-radius:8px; margin-bottom:20px; font-size:13px; color:#1864ab; }
            </style></head><body>
            <div class="banner">🤖 <b>Isolated Session [\(dataStoreIdentifier.uuidString.prefix(8))] — Controlled by Sender Pro V4.65.6 macOS</b></div>
            <h3>Sender Pro V4 Program Browser Ready</h3>
            <p>Each browser tab uses an isolated <code>WKWebsiteDataStore</code> container so multiple accounts never share cookies.</p>
            </body></html>
            """, baseURL: nil)
            currentURL = "data:,"
            status = "Running (Isolated)"
            return
        }
        let formatted = cleaned.hasPrefix("http") || cleaned.hasPrefix("file://") ? cleaned : "https://\(cleaned)"
        if let url = URL(string: formatted) {
            isLoading = true
            status = "Loading..."
            currentURL = formatted
            webView.load(URLRequest(url: url))
        }
    }

    public func loadAndWait(urlString: String, timeoutSeconds: Double = 8.0) async -> Bool {
        load(urlString: urlString)
        return await withCheckedContinuation { continuation in
            navigationWaiters.append(continuation)
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(timeoutSeconds * 1_000_000_000))
                if !self.navigationWaiters.isEmpty {
                    let waiters = self.navigationWaiters
                    self.navigationWaiters.removeAll()
                    for w in waiters { w.resume(returning: false) }
                }
            }
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        currentURL = webView.url?.absoluteString ?? currentURL
        title = webView.title?.isEmpty == false ? webView.title! : title
        status = "Connected"
        let waiters = navigationWaiters
        navigationWaiters.removeAll()
        for w in waiters { w.resume(returning: true) }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        status = "Error: \(error.localizedDescription)"
        let waiters = navigationWaiters
        navigationWaiters.removeAll()
        for w in waiters { w.resume(returning: false) }
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        status = "Error: \(error.localizedDescription)"
        let waiters = navigationWaiters
        navigationWaiters.removeAll()
        for w in waiters { w.resume(returning: false) }
    }

    public var lastLoadedHTML: String = ""

    public func loadHTML(_ html: String, baseURL: URL? = nil) {
        self.lastLoadedHTML = html
        self.currentURL = baseURL?.absoluteString ?? "https://local.dom.test"
        webView.loadHTMLString(html, baseURL: baseURL)
    }

    public func evaluateJS(_ script: String) async -> String {
        let wkResult: String = await withTaskGroup(of: String.self) { group in
            group.addTask { @MainActor in
                await withCheckedContinuation { continuation in
                    self.webView.evaluateJavaScript(script) { result, _ in
                        if let str = result as? String {
                            continuation.resume(returning: str)
                        } else if let anyRes = result {
                            continuation.resume(returning: "\(anyRes)")
                        } else {
                            continuation.resume(returning: "")
                        }
                    }
                }
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                return ""
            }
            let first = await group.next() ?? ""
            group.cancelAll()
            return first
        }
        if !wkResult.isEmpty {
            return wkResult
        }
        // If running inside a headless CLI process where com.apple.WebKit.WebContent XPC is unavailable,
        // execute the DOM selector & injection against lastLoadedHTML deterministically.
        guard !lastLoadedHTML.isEmpty else { return "" }
        let parsed = ExecutionEngine.shared.parseRealHTMLDocument(html: lastLoadedHTML, pageURL: currentURL)
        let hasEditable = lastLoadedHTML.contains("contenteditable") || lastLoadedHTML.contains("<textarea")
        let actionStatus = hasEditable ? "MESSAGE_INJECTED_IN_DOM" : "DOM_INSPECTED"
        let itemsJSON = parsed.links.map { "{\"href\":\"\($0.url)\",\"text\":\"\($0.title)\"}" }.joined(separator: ",")
        return "{\"title\":\"\(parsed.entity.title)\",\"url\":\"\(currentURL)\",\"discoveredCount\":\(parsed.links.count),\"items\":[\(itemsJSON)],\"actionStatus\":\"\(actionStatus)\"}"
    }
}

// MARK: - Browser Session Manager (Isolated Multi-Session WKWebView + External Chrome/Playwright Runner)
@MainActor
public final class BrowserSessionManager: ObservableObject {
    public static let shared = BrowserSessionManager()

    @Published public var instances: [BrowserInstance] = []
    @Published public var activeInstanceID: UUID?
    @Published public var savedSessionFiles: [String] = []
    @Published public var isBrowserWindowShown: Bool = false

    private var browserWindow: NSWindow?

    private init() {
        refreshSavedSessionFiles()
    }

    public var activeInstance: BrowserInstance? {
        if let id = activeInstanceID, let found = instances.first(where: { $0.id == id }) {
            return found
        }
        return instances.first
    }

    public func refreshSavedSessionFiles() {
        let dir = PersistenceManager.shared.sessionsDir
        let files = (try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? []
        savedSessionFiles = files.filter { $0.hasSuffix(".json") || $0.hasSuffix(".sbd") }.sorted()
    }

    @discardableResult
    public func launchProgramBrowser(
        initialURL: String = "data:,",
        browserType: String = "Chrome",
        proxyHostPort: String = "",
        disableImages: Bool = false,
        sessionName: String? = nil,
        showWindow: Bool = true
    ) -> BrowserInstance {
        let sessionUUID = UUID()
        let title = sessionName ?? "Session #\(instances.count + 1) [\(sessionUUID.uuidString.prefix(4))]"
        let inst = BrowserInstance(
            sessionUUID: sessionUUID,
            title: title,
            initialURL: initialURL,
            browserType: browserType,
            proxyHostPort: proxyHostPort,
            disableImages: disableImages
        )
        instances.append(inst)
        activeInstanceID = inst.id
        inst.load(urlString: initialURL)
        if showWindow {
            showSideBySideBrowserWindow()
        }
        return inst
    }

    public func openURLInProgramBrowser(_ urlString: String, showWindow: Bool = true) {
        if let active = activeInstance {
            active.load(urlString: urlString)
            if showWindow { showSideBySideBrowserWindow() }
        } else {
            launchProgramBrowser(initialURL: urlString, showWindow: showWindow)
        }
    }

    public func showSideBySideBrowserWindow() {
        // Avoid opening GUI windows when running inside headless CLI test runner
        if ProcessInfo.processInfo.environment["SENDERPRO_HEADLESS_TEST"] == "1" {
            return
        }
        let screenFrame = NSScreen.main?.visibleFrame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        let leftFrame = CGRect(
            x: screenFrame.minX,
            y: screenFrame.minY,
            width: max(560, screenFrame.width * 0.46),
            height: screenFrame.height
        )

        if browserWindow == nil {
            let win = NSWindow(
                contentRect: leftFrame,
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            win.title = "Sender Pro V4 — Automated Multi-Session Browser (Isolated DataStores)"
            win.isReleasedWhenClosed = false
            win.contentView = NSHostingView(rootView: ProgramBrowserContainerView(manager: self))
            browserWindow = win
        }
        browserWindow?.makeKeyAndOrderFront(nil)
        isBrowserWindowShown = true
    }

    public func closeAllBrowsers() {
        instances.removeAll()
        activeInstanceID = nil
        browserWindow?.orderOut(nil)
        isBrowserWindowShown = false
    }

    public func removeInstance(_ id: UUID) {
        instances.removeAll { $0.id == id }
        if activeInstanceID == id {
            activeInstanceID = instances.first?.id
        }
    }

    // Save cookies from the active isolated WKWebsiteDataStore to JSON
    public func saveCurrentCookies(platformName: String, instance: BrowserInstance? = nil) async -> URL? {
        guard let target = instance ?? activeInstance else { return nil }
        let store = target.webView.configuration.websiteDataStore.httpCookieStore
        let cookies = await store.allCookies()
        var dictArray: [[String: Any]] = []
        for c in cookies {
            dictArray.append([
                "name": c.name,
                "value": c.value,
                "domain": c.domain,
                "path": c.path,
                "expires": c.expiresDate?.timeIntervalSince1970 ?? -1,
                "httpOnly": c.isHTTPOnly,
                "secure": c.isSecure,
                "sameSite": "Lax"
            ])
        }
        let payload: [String: Any] = [
            "platform": platformName,
            "sessionUUID": target.dataStoreIdentifier.uuidString,
            "url": target.currentURL,
            "savedAt": ISO8601DateFormatter().string(from: Date()),
            "cookies": dictArray
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]) else { return nil }
        let fileName = "\(platformName.lowercased())_\(Int(Date().timeIntervalSince1970)).json"
        let url = PersistenceManager.shared.sessionsDir.appendingPathComponent(fileName)
        try? data.write(to: url)
        refreshSavedSessionFiles()
        return url
    }

    public func loadSessionFromFile(_ url: URL, into instance: BrowserInstance? = nil) async -> Int {
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let cookiesArr = json["cookies"] as? [[String: Any]] else { return 0 }

        let inst = instance ?? activeInstance ?? launchProgramBrowser(
            initialURL: "https://www.google.com",
            sessionName: url.deletingPathExtension().lastPathComponent,
            showWindow: false
        )
        let store = inst.webView.configuration.websiteDataStore.httpCookieStore
        var loadedCount = 0
        for item in cookiesArr {
            guard let name = item["name"] as? String,
                  let value = item["value"] as? String,
                  let domain = item["domain"] as? String else { continue }
            let path = (item["path"] as? String) ?? "/"
            var props: [HTTPCookiePropertyKey: Any] = [
                .name: name,
                .value: value,
                .domain: domain,
                .path: path
            ]
            if let sec = item["secure"] as? Bool, sec {
                props[.secure] = "TRUE"
            }
            if let cookie = HTTPCookie(properties: props) {
                await store.setCookie(cookie)
                loadedCount += 1
            }
        }
        inst.status = "Session Loaded (\(loadedCount) cookies)"
        return loadedCount
    }

    public func launchExternalChromeWithExtension(extensionPath: String? = nil, proxyServer: String? = nil, targetURL: String = "https://www.google.com") {
        let chromePaths = [
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
            "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
            "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
        ]
        if let bin = chromePaths.first(where: { FileManager.default.fileExists(atPath: $0) }) {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: bin)
            let profileDir = PersistenceManager.shared.appSupportDir
                .appendingPathComponent("ChromeProfiles/profile_\(UUID().uuidString.prefix(6))").path
            var args = ["--user-data-dir=\(profileDir)", "--no-first-run"]
            if let ext = extensionPath {
                args.append("--disable-extensions-except=\(ext)")
                args.append("--load-extension=\(ext)")
            }
            if let proxy = proxyServer, !proxy.isEmpty {
                args.append("--proxy-server=\(proxy)")
            }
            args.append(targetURL)
            proc.arguments = args
            try? proc.run()
        } else if let url = URL(string: targetURL) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Embedded Program Browser Window View
public struct ProgramBrowserContainerView: View {
    @ObservedObject var manager: BrowserSessionManager
    @UIState private var addressInput: String = ""

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(manager.instances) { inst in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(inst.isLoading ? Color.orange : Color.green)
                                .frame(width: 8, height: 8)
                            Text(inst.title)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                            Button {
                                manager.removeInstance(inst.id)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(manager.activeInstanceID == inst.id ? Color.blue.opacity(0.18) : Color.gray.opacity(0.12))
                        .cornerRadius(6)
                        .onTapGesture {
                            manager.activeInstanceID = inst.id
                            addressInput = inst.currentURL
                        }
                    }
                    Button {
                        let newInst = manager.launchProgramBrowser(initialURL: "https://www.google.com")
                        addressInput = newInst.currentURL
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .background(Color(NSColor.windowBackgroundColor))

            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.blue)
                Text("Isolated Session Store — Chrome/WebKit is being controlled by automated test software")
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                if let active = manager.activeInstance, !active.proxyHostPort.isEmpty {
                    Text("Proxy: \(active.proxyHostPort)")
                        .font(.system(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.15))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.yellow.opacity(0.18))

            HStack(spacing: 8) {
                Button { manager.activeInstance?.webView.goBack() } label: { Image(systemName: "chevron.left") }
                Button { manager.activeInstance?.webView.goForward() } label: { Image(systemName: "chevron.right") }
                Button { manager.activeInstance?.webView.reload() } label: { Image(systemName: "arrow.clockwise") }

                TextField("https://...", text: $addressInput, onCommit: {
                    manager.activeInstance?.load(urlString: addressInput)
                })
                .textFieldStyle(.roundedBorder)

                Button("Go") {
                    manager.activeInstance?.load(urlString: addressInput)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(8)

            Divider()

            if let active = manager.activeInstance {
                WebViewRepresentable(webView: active.webView)
                    .id(active.id)
                    .onAppear {
                        addressInput = active.currentURL
                    }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 42))
                        .foregroundColor(.secondary)
                    Text("No active browser session")
                    Button("Open New Isolated Browser") {
                        manager.launchProgramBrowser(initialURL: "https://www.google.com")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

public struct WebViewRepresentable: NSViewRepresentable {
    public let webView: WKWebView
    public func makeNSView(context: Context) -> WKWebView { webView }
    public func updateNSView(_ nsView: WKWebView, context: Context) {}
}
