import SwiftUI
import AppKit

// MARK: - Complete Sender Pro V4 Marketing Workspace View (Videos V01-V10)
public struct MarketingWorkspaceView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @ObservedObject var engine = ExecutionEngine.shared
    @ObservedObject var browserMgr = BrowserSessionManager.shared

    @UIState private var selectedPlatform: MarketingPlatform = .dashboard
    @UIState private var selectedSubMenu: String = "Account"
    @UIState private var activeTool: MarketingToolCard? = nil

    // Modals triggered from tools
    @UIState private var showManageBrowsersModal: Bool = false
    @UIState private var browserModalMode: BrowserModalType = .cookiesAndProxy
    @UIState private var browserModalPlatform: String = "Facebook"
    @UIState private var showManageContentModal: Bool = false

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            // Left Vertical Scrollable Sidebar (Exact replica of Windows MainSideButtons)
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(MarketingPlatform.allCases) { platform in
                        VStack(alignment: .leading, spacing: 2) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if selectedPlatform == platform {
                                        activeTool = nil
                                    } else {
                                        selectedPlatform = platform
                                        selectedSubMenu = platform.subMenus.first ?? ""
                                        activeTool = nil
                                    }
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(selectedPlatform == platform ? Color.blue : Color.clear)
                                        .frame(width: 4, height: 26)

                                    Image(systemName: platform.iconName)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(platform.brandColor)
                                        .cornerRadius(6)

                                    Text(platform.rawValue)
                                        .font(.system(size: 13, weight: selectedPlatform == platform ? .bold : .medium))
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Image(systemName: selectedPlatform == platform ? "chevron.down" : "chevron.right")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 5)
                                .padding(.trailing, 10)
                                .background(selectedPlatform == platform ? Color.blue.opacity(0.10) : Color.clear)
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)

                            // Nested Sub-Menus when Platform is selected (Matching V01-V10 Sidebar Expansion)
                            if selectedPlatform == platform {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(platform.subMenus, id: \.self) { sub in
                                        Button {
                                            selectedSubMenu = sub
                                            let tools = ToolCatalog.tools(for: platform, subMenu: sub)
                                            if tools.count == 1 {
                                                activeTool = tools.first
                                            } else {
                                                activeTool = nil
                                            }
                                        } label: {
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(selectedSubMenu == sub ? platform.brandColor : Color.gray.opacity(0.4))
                                                    .frame(width: 6, height: 6)
                                                Text(sub)
                                                    .font(.system(size: 12, weight: selectedSubMenu == sub ? .bold : .regular))
                                                    .foregroundColor(selectedSubMenu == sub ? platform.brandColor : .secondary)
                                                Spacer()
                                            }
                                            .padding(.leading, 36)
                                            .padding(.vertical, 5)
                                            .background(selectedSubMenu == sub ? platform.brandColor.opacity(0.08) : Color.clear)
                                            .cornerRadius(5)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.bottom, 4)
                            }
                        }
                    }
                }
                .padding(8)
            }
            .frame(width: 215)
            .background(persistence.isDarkMode ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
            .overlay(Divider(), alignment: .trailing)

            // Main Workspace Area
            ZStack {
                if selectedPlatform == .dashboard {
                    if selectedSubMenu == "Security" {
                        DashboardSecurityView()
                    } else {
                        DashboardAccountsGridView { platName, mode in
                            browserModalPlatform = platName
                            browserModalMode = mode
                            showManageBrowsersModal = true
                        }
                    }
                } else if let tool = activeTool {
                    ToolExecutionPanelView(
                        tool: tool,
                        onBack: {
                            let allInSub = ToolCatalog.tools(for: selectedPlatform, subMenu: selectedSubMenu)
                            if allInSub.count > 1 {
                                activeTool = nil
                            }
                        },
                        onOpenBrowsers: {
                            browserModalPlatform = tool.platform.rawValue
                            browserModalMode = tool.browserModalType
                            showManageBrowsersModal = true
                        },
                        onOpenContent: {
                            showManageContentModal = true
                        }
                    )
                    .id(tool.id)
                } else {
                    let tools = ToolCatalog.tools(for: selectedPlatform, subMenu: selectedSubMenu)
                    if tools.count == 1, let single = tools.first {
                        ToolExecutionPanelView(
                            tool: single,
                            onBack: {},
                            onOpenBrowsers: {
                                browserModalPlatform = single.platform.rawValue
                                browserModalMode = single.browserModalType
                                showManageBrowsersModal = true
                            },
                            onOpenContent: {
                                showManageContentModal = true
                            }
                        )
                        .id(single.id)
                    } else {
                        ToolCardsGridView(
                            platform: selectedPlatform,
                            subMenu: selectedSubMenu,
                            tools: tools,
                            onSelectTool: { chosen in
                                activeTool = chosen
                            }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(persistence.isDarkMode ? Color(red: 0.11, green: 0.12, blue: 0.14) : Color(red: 0.96, green: 0.97, blue: 0.99))
        }
        .sheet(isPresented: $showManageBrowsersModal) {
            ManageBrowsersModalView(initialMode: browserModalMode, platformName: browserModalPlatform)
        }
        .sheet(isPresented: $showManageContentModal) {
            ManageContentModalView()
        }
    }
}

// MARK: - 1. Dashboard > Account 3x3 Grid (Exact replica of V01 00:12 - 03:36)
public struct DashboardAccountsGridView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    public var onSelectPlatformAccount: (String, BrowserModalType) -> Void

    private let cards: [(titleAr: String, titleEn: String, btnAr: String, icon: String, color: Color, plat: String, mode: BrowserModalType)] = [
        ("اداره حسابات الفيس بوك", "Manage Facebook Accounts", "حسابات الفيس بوك", "f.square.fill", Color(red: 0.09, green: 0.47, blue: 0.95), "Facebook", .cookiesAndProxy),
        ("اداره حسابات الانستجرام", "Manage Instagram Accounts", "حسابات الانستجرام", "camera.aperture", Color(red: 0.88, green: 0.19, blue: 0.42), "Instagram", .cookiesAndProxy),
        ("اداره حسابات تويتر", "Manage Twitter Accounts", "حسابات تويتر", "bird.fill", Color(red: 0.11, green: 0.63, blue: 0.95), "Twitter", .cookiesAndProxy),
        ("اداره حسابات لينكدان", "Manage LinkedIn Accounts", "حسابات لينكدان", "briefcase.fill", Color(red: 0.04, green: 0.40, blue: 0.76), "LinkedIn", .cookiesAndProxy),
        ("اداره حسابات تليجرام", "Manage Telegram Accounts", "حسابات تليجرام", "paperplane.circle.fill", Color(red: 0.15, green: 0.64, blue: 0.89), "Telegram", .telegramMTProto),
        ("اداره حسابات بنترست", "Manage Pinterest Accounts", "حسابات بنترست", "pin.circle.fill", Color(red: 0.90, green: 0.00, blue: 0.14), "Pinterest", .cookiesAndProxy),
        ("اداره حسابات في كا", "Manage VK Accounts", "حسابات في كا", "person.2.square.stack.fill", Color(red: 0.00, green: 0.47, blue: 0.84), "VK", .cookiesAndProxy),
        ("اداره حسابات ريديت", "Manage Reddit Accounts", "حسابات ريديت", "bubble.left.and.exclamationmark.bubble.right.fill", Color(red: 1.00, green: 0.27, blue: 0.00), "Reddit", .cookiesAndProxy),
        ("اداره حسابات تيك توك", "Manage TikTok Accounts", "حسابات تيك توك", "music.note.tv.fill", Color(red: 0.10, green: 0.10, blue: 0.14), "TikTok", .sessionList)
    ]

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(cards, id: \.plat) { card in
                    VStack(spacing: 12) {
                        Text(persistence.isArabic ? card.titleAr : card.titleEn)
                            .font(.system(size: 14, weight: .bold))

                        Image(systemName: card.icon)
                            .font(.system(size: 38))
                            .foregroundColor(.white)
                            .frame(width: 68, height: 68)
                            .background(card.color)
                            .cornerRadius(14)

                        Text(persistence.isArabic
                             ? "اداره وحفظ جميع \(card.btnAr) على متصفح جوجل كروم"
                             : "Manage and save all \(card.plat) sessions in Chrome")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)

                        Button {
                            onSelectPlatformAccount(card.plat, card.mode)
                        } label: {
                            Text(persistence.isArabic ? card.btnAr : "Manage \(card.plat)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 170, height: 34)
                                .background(Color(red: 0.09, green: 0.56, blue: 1.0))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .background(persistence.isDarkMode ? Color(red: 0.16, green: 0.17, blue: 0.21) : Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                    )
                }
            }
            .padding(20)
        }
    }
}

// MARK: - 2. Dashboard > Security View (Exact replica of V01 01:00 & V10 04:52)
public struct DashboardSecurityView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    @UIState private var savedBanner: String = ""

    public var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left panel: Random Keywords (إضافة كلمات عشوائية لاستخدامها في المحتوى)
            VStack(alignment: .trailing, spacing: 14) {
                HStack {
                    Spacer()
                    Text("إضافة كلمات عشوائية لاستخدامها في المحتوى")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(6)
                }

                Text("ادخل كلمات مفتاحية وقم بالفصل بينهم بعلامة  -")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)

                TextEditor(text: $persistence.securityConfig.randomKeywordsRaw)
                    .font(.system(size: 13))
                    .frame(height: 180)
                    .border(Color.gray.opacity(0.25))

                Button {
                    persistence.saveSettings()
                    savedBanner = persistence.isArabic ? "تم حفظ الكلمات العشوائية وإعدادات الأمان بنجاح ✓" : "Security & Random Keywords saved ✓"
                } label: {
                    Text("حفظ الكلمات")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 240, height: 36)
                        .background(Color(red: 0.09, green: 0.56, blue: 1.0))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)

                Divider()

                VStack(alignment: .center, spacing: 8) {
                    Text("أو قم باستخدام الكلمات العشوائية")
                        .font(.system(size: 12, weight: .semibold))
                    Toggle("استخدم الكلمات العشوائية", isOn: $persistence.securityConfig.useRandomKeywords)
                        .font(.system(size: 12))
                }
                .frame(maxWidth: .infinity)

                if !savedBanner.isEmpty {
                    Text(savedBanner)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(persistence.isDarkMode ? Color(red: 0.16, green: 0.17, blue: 0.21) : Color.white)
            .cornerRadius(10)

            // Right panel: Additional Random Time Intervals (فواصل زمنية إضافية للأداة)
            VStack(alignment: .trailing, spacing: 18) {
                HStack {
                    Spacer()
                    Text("فواصل زمنية إضافية للأداة")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(6)
                }

                HStack(spacing: 16) {
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("أعلى وقت بالثواني (Max)")
                            .font(.system(size: 12, weight: .semibold))
                        Stepper(
                            "\(persistence.securityConfig.maxTimerSeconds) s",
                            value: $persistence.securityConfig.maxTimerSeconds,
                            in: 1...900
                        )
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }

                    Text("And")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    VStack(alignment: .trailing, spacing: 6) {
                        Text("أقل وقت بالثواني (Min)")
                            .font(.system(size: 12, weight: .semibold))
                        Stepper(
                            "\(persistence.securityConfig.minTimerSeconds) s",
                            value: $persistence.securityConfig.minTimerSeconds,
                            in: 0...600
                        )
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(persistence.isDarkMode ? Color(red: 0.16, green: 0.17, blue: 0.21) : Color.white)
            .cornerRadius(10)
        }
        .padding(20)
    }
}

// MARK: - 3. Tool Cards Grid View (For Submenus with Multiple Tools like Extract, Analysis, Marketing)
public struct ToolCardsGridView: View {
    @ObservedObject var persistence = PersistenceManager.shared
    public let platform: MarketingPlatform
    public let subMenu: String
    public let tools: [MarketingToolCard]
    public let onSelectTool: (MarketingToolCard) -> Void

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(tools) { tool in
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.pink)
                                .font(.system(size: 16))
                            Spacer()
                            Text(persistence.isArabic ? tool.titleAr : tool.titleEn)
                                .font(.system(size: 13, weight: .bold))
                                .multilineTextAlignment(.trailing)
                                .lineLimit(2)
                        }

                        Image(systemName: tool.iconName)
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .frame(width: 58, height: 58)
                            .background(platform.brandColor)
                            .cornerRadius(12)

                        Text(persistence.isArabic ? tool.descAr : tool.descEn)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .frame(height: 44)

                        Button {
                            onSelectTool(tool)
                        } label: {
                            Text(persistence.isArabic ? tool.buttonAr : tool.buttonEn)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 34)
                                .background(Color(red: 0.09, green: 0.56, blue: 1.0))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .background(persistence.isDarkMode ? Color(red: 0.16, green: 0.17, blue: 0.21) : Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                    )
                }
            }
            .padding(20)
        }
    }
}
