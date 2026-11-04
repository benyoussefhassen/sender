import Foundation
import SwiftUI

// MARK: - Top-Level Application Mode (Launcher Hub + 3 Programs + Extensions)
public enum AppProgramMode: String, CaseIterable, Identifiable, Codable {
    case marketing = "Sender Pro V4 Marketing"
    case b2bData = "Sender Pro B2B"
    case dataAnalysis = "Sender Pro Data Analysis"
    case extensions = "Chrome & Brave Extensions"
    case launcher = "Sender Pro Launcher"

    public var id: String { rawValue }

    public func localizedTitle(isArabic: Bool) -> String {
        switch self {
        case .marketing: return isArabic ? "Sender Pro V4 Marketing - برنامج التسويق" : "Sender Pro V4 Marketing"
        case .b2bData: return isArabic ? "Sender Pro B2B - برنامج الداتا" : "Sender Pro B2B"
        case .dataAnalysis: return isArabic ? "Sender Pro Data Analysis - برنامج التحليل" : "Sender Pro Data Analysis"
        case .extensions: return isArabic ? "إضافات جوجل كروم وبريف (15 أداة)" : "Chrome & Brave Extensions (15)"
        case .launcher: return isArabic ? "مشغل سيندر برو - Sender Pro Launcher" : "Sender Pro Launcher"
        }
    }
}

// MARK: - Marketing Sidebar Sections (Exact 20 entries observed in Videos V01-V10)
public enum MarketingPlatform: String, CaseIterable, Identifiable, Codable {
    case dashboard = "Dashboard"
    case facebook = "Facebook"
    case whatsapp = "Whatsapp"
    case instagram = "Instagram"
    case threads = "Threads"
    case twitter = "Twitter"
    case xPlus = "X Plus"
    case linkedIn = "LinkedIn"
    case telegram = "Telegram"
    case telegramPremium = "Premium"
    case snapchat = "SnapChat"
    case imo = "Imo"
    case pinterest = "Pinterest"
    case sendEmails = "Send Emails"
    case google = "Google"
    case vk = "Vk"
    case reddit = "Reddit"
    case autoPoint = "Auto Point"
    case tiktok = "TikTok"
    case otherTools = "Other Tools"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.67percent"
        case .facebook: return "f.square.fill"
        case .whatsapp: return "phone.bubble.left.fill"
        case .instagram: return "camera.aperture"
        case .threads: return "at.circle.fill"
        case .twitter: return "bird.fill"
        case .xPlus: return "xmark.square.fill"
        case .linkedIn: return "briefcase.fill"
        case .telegram: return "paperplane.circle.fill"
        case .telegramPremium: return "star.circle.fill"
        case .snapchat: return "bell.circle.fill"
        case .imo: return "message.circle.fill"
        case .pinterest: return "pin.circle.fill"
        case .sendEmails: return "envelope.fill"
        case .google: return "globe"
        case .vk: return "person.2.square.stack.fill"
        case .reddit: return "bubble.left.and.exclamationmark.bubble.right.fill"
        case .autoPoint: return "bolt.circle.fill"
        case .tiktok: return "music.note.tv.fill"
        case .otherTools: return "wrench.and.screwdriver.fill"
        }
    }

    public var brandColor: Color {
        switch self {
        case .dashboard: return Color(red: 0.15, green: 0.65, blue: 0.60)
        case .facebook: return Color(red: 0.09, green: 0.47, blue: 0.95)
        case .whatsapp: return Color(red: 0.15, green: 0.83, blue: 0.40)
        case .instagram: return Color(red: 0.88, green: 0.19, blue: 0.42)
        case .threads: return Color(red: 0.15, green: 0.15, blue: 0.18)
        case .twitter: return Color(red: 0.11, green: 0.63, blue: 0.95)
        case .xPlus: return Color(red: 0.22, green: 0.22, blue: 0.26)
        case .linkedIn: return Color(red: 0.04, green: 0.40, blue: 0.76)
        case .telegram: return Color(red: 0.15, green: 0.64, blue: 0.89)
        case .telegramPremium: return Color(red: 0.78, green: 0.62, blue: 0.18)
        case .snapchat: return Color(red: 0.95, green: 0.82, blue: 0.05)
        case .imo: return Color(red: 0.08, green: 0.52, blue: 0.92)
        case .pinterest: return Color(red: 0.90, green: 0.00, blue: 0.14)
        case .sendEmails: return Color(red: 0.85, green: 0.25, blue: 0.20)
        case .google: return Color(red: 0.26, green: 0.52, blue: 0.96)
        case .vk: return Color(red: 0.00, green: 0.47, blue: 0.84)
        case .reddit: return Color(red: 1.00, green: 0.27, blue: 0.00)
        case .autoPoint: return Color(red: 0.10, green: 0.55, blue: 0.95)
        case .tiktok: return Color(red: 0.08, green: 0.08, blue: 0.12)
        case .otherTools: return Color(red: 0.12, green: 0.60, blue: 0.88)
        }
    }

    public var subMenus: [String] {
        switch self {
        case .dashboard:
            return ["Security", "Account"]
        case .facebook:
            return ["Login", "Search", "Extract", "Analysis", "Marketing", "Broadcast", "Pages", "Mention", "Other Tools"]
        case .whatsapp:
            return ["Filter", "Extract", "Post In Groups", "Broadcast"]
        case .instagram:
            return ["Login", "Extract", "Marketing", "Follow", "Mention", "Broadcast"]
        case .threads:
            return ["Extract", "Mention", "Marketing"]
        case .twitter:
            return ["Login", "Extract", "Scheduled", "Mention", "Broadcast", "Follow", "Marketing", "Retweet"]
        case .xPlus:
            return ["Monitor & Engage", "Scheduled & Hashtags"]
        case .linkedIn:
            return ["Login", "Search", "Extract", "Marketing", "Broadcast"]
        case .telegram:
            return ["Extract", "Add User", "Broadcast", "Other Tools"]
        case .telegramPremium:
            return ["Hidden Members Extract", "Keyword Search", "Reactions & Transfer"]
        case .snapchat:
            return ["Broadcast"]
        case .imo:
            return ["Sender"]
        case .pinterest:
            return ["Login", "Search", "Accounts", "Extract", "Broadcast", "Follow", "Marketing"]
        case .sendEmails:
            return ["SMTP Campaign"]
        case .google:
            return ["SMS", "Google Rate", "Contacts"]
        case .vk:
            return ["Login", "Search", "Communities", "Extract", "Request", "Broadcast", "Mention"]
        case .reddit:
            return ["Login", "Search", "Vote Arrows", "Top Growing", "Publishing"]
        case .autoPoint:
            return ["Like4Like", "Getlike", "Other"]
        case .tiktok:
            return ["Extract", "Marketing", "Upload Videos"]
        case .otherTools:
            return ["Download", "Haraj Rate", "Magic Editor", "Text Editor", "Text As vcf", "Generate", "Hashtags"]
        }
    }
}

// MARK: - Tool Definition for Multi-Tool Submenus (Observed in V01-V10)
public enum ToolPanelKind: String, Codable {
    case standardScraperAndSender
    case loginForm
    case whatsappDualFilter
    case whatsappTripleFilter
    case facebookPostReactions
    case facebookGroupAnalyzer
    case facebookEngagementFarm
    case instagramEngagementFarm
    case twitterTrendsExtractor
    case twitterScheduled
    case twitterAccountChecker
    case telegramMemberExtractor
    case telegramProfileChanger
    case telegramBroadcast
    case pinterestAccountCreator
    case smtpFourStepWizard
    case autoPointExchange
    case videoBatchDownloader
    case magicFileEditor
    case textFileSplitter
    case vcfConverter
    case phoneGenerator
    case hashtagAnalyzer
}

public struct MarketingToolCard: Identifiable, Hashable, Codable {
    public let id: String
    public let platform: MarketingPlatform
    public let subMenu: String
    public let titleAr: String
    public let titleEn: String
    public let descAr: String
    public let descEn: String
    public let buttonAr: String
    public let buttonEn: String
    public let iconName: String
    public let columns: [String]
    public let panelKind: ToolPanelKind
    public let browserModalType: BrowserModalType
    public let defaultUrl: String

    public init(
        id: String,
        platform: MarketingPlatform,
        subMenu: String,
        titleAr: String,
        titleEn: String,
        descAr: String,
        descEn: String,
        buttonAr: String,
        buttonEn: String,
        iconName: String = "sparkles",
        columns: [String] = ["ID / Username", "Name", "State", "Time"],
        panelKind: ToolPanelKind = .standardScraperAndSender,
        browserModalType: BrowserModalType = .cookiesAndProxy,
        defaultUrl: String = "https://www.google.com"
    ) {
        self.id = id
        self.platform = platform
        self.subMenu = subMenu
        self.titleAr = titleAr
        self.titleEn = titleEn
        self.descAr = descAr
        self.descEn = descEn
        self.buttonAr = buttonAr
        self.buttonEn = buttonEn
        self.iconName = iconName
        self.columns = columns
        self.panelKind = panelKind
        self.browserModalType = browserModalType
        self.defaultUrl = defaultUrl
    }
}

public enum BrowserModalType: String, Codable {
    case cookiesAndProxy // Type A (V01 01:24)
    case sessionList     // Type B (V01 02:04)
    case telegramMTProto // Type C (V01 02:40)
}

// MARK: - Sender Pro B2B Connectors (Exact 29 entries observed in Video V11)
public struct B2BConnectorSpec: Identifiable, Hashable, Codable {
    public let id: String
    public let sidebarName: String
    public let titleAr: String
    public let portalUrl: String
    public let openButtonLabel: String
    public let columns: [String]
    public let countries: [String]
    public let supportsEmailWhatsAppToggle: Bool
    public let isSingleStage: Bool

    public init(
        id: String,
        sidebarName: String,
        titleAr: String,
        portalUrl: String,
        openButtonLabel: String,
        columns: [String],
        countries: [String] = [],
        supportsEmailWhatsAppToggle: Bool = false,
        isSingleStage: Bool = false
    ) {
        self.id = id
        self.sidebarName = sidebarName
        self.titleAr = titleAr
        self.portalUrl = portalUrl
        self.openButtonLabel = openButtonLabel
        self.columns = columns
        self.countries = countries
        self.supportsEmailWhatsAppToggle = supportsEmailWhatsAppToggle
        self.isSingleStage = isSingleStage
    }
}

// MARK: - Persistent Entities (Accounts, Content Templates, Logs, Security Settings)
public struct SocialAccountRecord: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var platform: String
    public var usernameOrEmail: String
    public var password: String
    public var twoFactorSecret: String
    public var proxyHostPort: String
    public var proxyUsername: String
    public var proxyPassword: String
    public var browserType: String // Chrome / Firefox / WebKit
    public var sessionFilePath: String
    public var isConnected: Bool
    public var cookiesJson: String
    public var createdAt: Date = Date()
}

public struct TelegramSessionRecord: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var name: String
    public var phone: String
    public var apiId: String
    public var apiHash: String
    public var sessionPath: String
    public var isConnected: Bool
    public var isSelected: Bool
}

public struct ContentTemplateRecord: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var name: String
    public var content: String
    public var contentLabel: String
    public var mediaPaths: [String]
    public var useRandomMediaCount: Int
    public var isSelected: Bool
    public var createdAt: Date = Date()
}

public struct SecurityConfig: Codable, Equatable {
    public var randomKeywordsRaw: String = "مساء الخير - أهلا بك يا فندم - تحياتي لك - السلام عليكم - مرحبا بك"
    public var useRandomKeywords: Bool = true
    public var minTimerSeconds: Int = 5
    public var maxTimerSeconds: Int = 15
    public var defaultDelaySeconds: Int = 5
    public var stopEveryCount: Int = 50
    public var waitMinutesOnStop: Int = 5
}

public struct ToolActivityLog: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    public var userEmail: String = "benyoussef.hassen@gmail.com"
    public var platform: String
    public var toolName: String
    public var operationType: String // Extract / Broadcast / Publish / Filter / B2B
    public var status: String        // Success / Failed
    public var itemsCount: Int
    public var details: String
}

public struct SMTPAccountEntry: Identifiable, Codable, Hashable {
    public var id: UUID = UUID()
    public var email: String
    public var appPassword: String
    public var sendLimitCount: Int
    public var smtpHost: String
    public var smtpPort: Int
    public var useSSL: Bool
}

public struct SMTPServerPreset: Identifiable, Hashable {
    public let id = UUID()
    public let provider: String
    public let smtpHost: String
    public let smtpPortSSL: Int
    public let smtpPortTLS: Int
    public let pop3Host: String
    public let pop3PortSSL: Int
}


// MARK: - UIState PropertyWrapper (Compatible with CommandLineTools SDK without SwiftUIMacros plugin)
@propertyWrapper
public struct UIState<Value>: DynamicProperty {
    @StateObject private var storage: Storage<Value>
    public final class Storage<T>: ObservableObject {
        @Published public var value: T
        public init(_ value: T) { self.value = value }
    }
    public init(wrappedValue: Value) {
        _storage = StateObject(wrappedValue: Storage(wrappedValue))
    }
    public init(initialValue: Value) {
        _storage = StateObject(wrappedValue: Storage(initialValue))
    }
    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }
    public var projectedValue: Binding<Value> {
        Binding(get: { storage.value }, set: { storage.value = $0 })
    }
}
