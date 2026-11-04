import Foundation

// MARK: - 4-Tier Regulatory & Technical Classification for Social Platform Capabilities
public enum SocialCapabilityTier: String, Codable, Sendable {
    case publicNoAuth = "PUBLIC_NO_AUTH"                     // Works without login on public URLs/pages/feeds
    case userSessionAuth = "USER_SESSION_AUTH"               // Works via real DOM/JS automation when user is logged in to WKWebView
    case officialAPIAuth = "OFFICIAL_API_AUTH"               // Works via official platform REST/Graph/Bot API token
    case prohibitedOrUnavailable = "PROHIBITED_OR_UNAVAILABLE" // Blocked by platform anti-abuse/CAPTCHA or prohibited without bypass
}

public struct SocialPlatformCapabilityMatrix: Sendable {
    public let platform: MarketingPlatform
    public let publicCapabilities: [String]
    public let sessionAuthenticatedCapabilities: [String]
    public let officialAPICapabilities: [String]
    public let prohibitedOrRestrictedCapabilities: [String]
    public let authDetectionCookieNames: [String]
    public let domSelectors: [String: String]
}

// MARK: - Real JavaScript / DOM Automation & Auth Verification Engine for Social Platforms
@MainActor
public final class SocialAutomationEngine {
    public static let shared = SocialAutomationEngine()

    public let platformMatrices: [MarketingPlatform: SocialPlatformCapabilityMatrix]

    private init() {
        let list: [SocialPlatformCapabilityMatrix] = [
            SocialPlatformCapabilityMatrix(
                platform: .facebook,
                publicCapabilities: [
                    "Public Page metadata & OpenGraph extraction (fb_search, fb_pages)",
                    "Public Group URL & post link discovery",
                    "URL-to-UID canonical link resolution (URL_TO_IDS)"
                ],
                sessionAuthenticatedCapabilities: [
                    "Login & persistent cookie session isolation (fb_login -> WKWebsiteDataStore)",
                    "Group Member extraction via DOM auto-scroll (Extract_Member)",
                    "Post Reactions & Comments DOM extraction (Comment_Line_Cookies)",
                    "Automated Group/Page Post publishing & Commenting in authenticated WKWebView",
                    "Messenger Broadcast to existing conversations in authenticated WKWebView"
                ],
                officialAPICapabilities: [
                    "Facebook Graph API Page Replies & Inbox management (FacebookAPIManager / access_token)"
                ],
                prohibitedOrRestrictedCapabilities: [
                    "Bypassing Facebook 2FA / Checkpoint challenges without user interaction",
                    "Scraping private profile friends lists when hidden by user privacy settings"
                ],
                authDetectionCookieNames: ["c_user", "xs"],
                domSelectors: [
                    "postLinks": "a[href*='/posts/'], a[href*='/permalink/'], a[href*='/groups/']",
                    "memberLinks": "a[href*='/user/'], a[role='link'][href*='facebook.com/']",
                    "commentBox": "div[contenteditable='true'][role='textbox']",
                    "likeButton": "div[aria-label='Like'], div[aria-label='أعجبني']"
                ]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .whatsapp,
                publicCapabilities: [
                    "Extracting wa.me/ and chat.whatsapp.com/ group invite links from web pages & search results",
                    "Validating phone number E.164 formatting & generating vCard (.vcf) contact bundles"
                ],
                sessionAuthenticatedCapabilities: [
                    "WhatsApp Web QR Code session persistence in isolated WKWebsiteDataStore",
                    "Extracting participant phone numbers from joined WhatsApp Web groups via DOM inspection",
                    "Sending Broadcast messages & media in WhatsApp Web via DOM compose box & send button",
                    "Checking number registration status via web.whatsapp.com/send?phone=..."
                ],
                officialAPICapabilities: [
                    "WhatsApp Business Cloud API (Graph API /messages endpoint with Bearer token)"
                ],
                prohibitedOrRestrictedCapabilities: [
                    "Headless WhatsApp login without scanning QR code or linking phone code on user device"
                ],
                authDetectionCookieNames: ["wa_ul", "wa_build"],
                domSelectors: [
                    "chatList": "div[aria-label='Chat list'], #pane-side",
                    "messageInput": "div[contenteditable='true'][data-tab='10'], footer div[contenteditable='true']",
                    "sendButton": "button[aria-label='Send'], span[data-icon='send']",
                    "invalidNumberModal": "div[data-animate-modal-popup='true']"
                ]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .instagram,
                publicCapabilities: [
                    "Public profile bio, title, OpenGraph & external link extraction",
                    "Hashtag expansion & public post link discovery"
                ],
                sessionAuthenticatedCapabilities: [
                    "Session login & cookie persistence (sessionid, ds_user_id)",
                    "Followers / Following / Likers / Commenters DOM list extraction via modal auto-scroll",
                    "Automated Like, Comment, Follow & Direct Message in authenticated WKWebView"
                ],
                officialAPICapabilities: [
                    "Instagram Graph API for Business/Creator accounts"
                ],
                prohibitedOrRestrictedCapabilities: [
                    "Bypassing Instagram suspicious login challenge / SMS verification"
                ],
                authDetectionCookieNames: ["sessionid", "ds_user_id"],
                domSelectors: [
                    "postLinks": "a[href*='/p/'], a[href*='/reel/']",
                    "userLinks": "a[role='link'][href^='/']",
                    "commentInput": "textarea[aria-label*='comment'], textarea[placeholder*='comment']",
                    "likeButton": "svg[aria-label='Like'], svg[aria-label='أعجبني']"
                ]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .threads,
                publicCapabilities: [
                    "Public Threads post & profile metadata extraction (threads.net)"
                ],
                sessionAuthenticatedCapabilities: [
                    "Authenticated post reply, mention & like in WKWebView"
                ],
                officialAPICapabilities: [
                    "Threads Publishing & Insights API (graph.threads.net)"
                ],
                prohibitedOrRestrictedCapabilities: [
                    "Unauthenticated bulk scraping blocked by Meta login wall"
                ],
                authDetectionCookieNames: ["csrftoken", "sessionid"],
                domSelectors: [
                    "postLinks": "a[href*='/post/']",
                    "userLinks": "a[href^='/@']"
                ]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .twitter,
                publicCapabilities: [
                    "Public trends extraction (trends24.in / public X syndication)",
                    "Public tweet OpenGraph & link discovery"
                ],
                sessionAuthenticatedCapabilities: [
                    "X.com session persistence (auth_token, ct0)",
                    "Tweet search, follower list auto-scroll, Like, Retweet, Bookmark, Reply & DM in WKWebView",
                    "Scheduled tweet execution at target DatePicker timestamp"
                ],
                officialAPICapabilities: [
                    "X API v2 (/2/tweets, /2/users) with OAuth 2.0 / Bearer Token"
                ],
                prohibitedOrRestrictedCapabilities: [
                    "Unauthenticated search scraping on x.com (requires auth_token cookie since 2023)"
                ],
                authDetectionCookieNames: ["auth_token", "ct0"],
                domSelectors: [
                    "tweetArticles": "article[data-testid='tweet']",
                    "tweetText": "div[data-testid='tweetText']",
                    "likeButton": "button[data-testid='like']",
                    "retweetButton": "button[data-testid='retweet']",
                    "replyInput": "div[data-testid='tweetTextarea_0']"
                ]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .xPlus,
                publicCapabilities: ["Public hashtag & trend monitoring"],
                sessionAuthenticatedCapabilities: ["Multi-account engagement farm (Like + Bookmark + Comment + Repost) in isolated WKWebViews"],
                officialAPICapabilities: ["X API v2 filtered stream"],
                prohibitedOrRestrictedCapabilities: ["Bypassing X Arkose FunCaptcha challenges"],
                authDetectionCookieNames: ["auth_token", "ct0"],
                domSelectors: ["tweetArticles": "article[data-testid='tweet']"]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .linkedIn,
                publicCapabilities: [
                    "Public company & job listing metadata extraction (JSON-LD / OpenGraph)"
                ],
                sessionAuthenticatedCapabilities: [
                    "LinkedIn session persistence (li_at)",
                    "People search, Group member extraction, Connect invitation & messaging in WKWebView"
                ],
                officialAPICapabilities: [
                    "LinkedIn Marketing & Share on LinkedIn API"
                ],
                prohibitedOrRestrictedCapabilities: [
                    "Bypassing LinkedIn commercial use limit or security CAPTCHA"
                ],
                authDetectionCookieNames: ["li_at", "JSESSIONID"],
                domSelectors: [
                    "profileLinks": "a[href*='/in/'], a[href*='/company/']",
                    "connectButton": "button[aria-label*='Invite'], button[aria-label*='Connect']"
                ]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .telegram,
                publicCapabilities: [
                    "Public channel & group web preview scraping (https://t.me/s/<channel>) — messages, views, links & member counts without login"
                ],
                sessionAuthenticatedCapabilities: [
                    "Telegram Web (web.telegram.org) session persistence",
                    "MTProto session (.session SQLite) management, OTP login & group extraction via TelegramMTProtoEngine"
                ],
                officialAPICapabilities: [
                    "Telegram Bot HTTP API (getMe, getChat, getChatMemberCount, getChatAdministrators, sendMessage)"
                ],
                prohibitedOrRestrictedCapabilities: [
                    "Extracting hidden member lists from private groups where admins disabled member visibility"
                ],
                authDetectionCookieNames: ["stel_ssid", "stel_token"],
                domSelectors: [
                    "channelMessages": "div.tgme_widget_message_text",
                    "channelLinks": "a.tgme_widget_message_date"
                ]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .telegramPremium,
                publicCapabilities: ["Public channel keyword & message search on t.me/s/"],
                sessionAuthenticatedCapabilities: ["Active commenter extraction from public/joined discussion groups"],
                officialAPICapabilities: ["Telegram MTProto channels.getParticipants (for authorized admins/members)"],
                prohibitedOrRestrictedCapabilities: ["Bypassing Telegram FloodWait or server-side hidden participant flags"],
                authDetectionCookieNames: ["stel_ssid"],
                domSelectors: ["channelMessages": "div.tgme_widget_message_text"]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .pinterest,
                publicCapabilities: [
                    "Public Pin & Board scraping (links, images, titles, descriptions)"
                ],
                sessionAuthenticatedCapabilities: [
                    "Authenticated Pin saving, commenting, following & messaging in WKWebView"
                ],
                officialAPICapabilities: ["Pinterest REST API v5"],
                prohibitedOrRestrictedCapabilities: [
                    "Automated bulk account registration (pin_accounts) blocked by Pinterest reCAPTCHA / email verification"
                ],
                authDetectionCookieNames: ["_pinterest_sess"],
                domSelectors: ["pinLinks": "a[href*='/pin/']"]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .tiktok,
                publicCapabilities: [
                    "Public TikTok profile & video metadata extraction (__UNIVERSAL_DATA_FOR_REHYDRATION__)"
                ],
                sessionAuthenticatedCapabilities: [
                    "Authenticated video comment, like, follow & video upload studio in WKWebView"
                ],
                officialAPICapabilities: ["TikTok Content Posting & Research API"],
                prohibitedOrRestrictedCapabilities: ["Bypassing TikTok puzzle slider CAPTCHA"],
                authDetectionCookieNames: ["sessionid", "sid_tt"],
                domSelectors: ["videoLinks": "a[href*='/video/']"]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .vk,
                publicCapabilities: ["Public VK community & profile metadata extraction (vk.com)"],
                sessionAuthenticatedCapabilities: ["Authenticated VK friend request, wall post & direct message in WKWebView"],
                officialAPICapabilities: ["VK API (api.vk.com/method/)"],
                prohibitedOrRestrictedCapabilities: ["Bypassing VK captcha_sid without user input"],
                authDetectionCookieNames: ["remixsid", "remixnsid"],
                domSelectors: ["postLinks": "a[href*='/wall']"]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .reddit,
                publicCapabilities: [
                    "Public subreddit & post extraction via Reddit JSON feed (https://www.reddit.com/r/<sub >/hot.json)"
                ],
                sessionAuthenticatedCapabilities: [
                    "Authenticated Reddit upvote, comment & post submission in WKWebView"
                ],
                officialAPICapabilities: ["Reddit OAuth2 API"],
                prohibitedOrRestrictedCapabilities: ["Automated vote manipulation prohibited by Reddit Content Policy"],
                authDetectionCookieNames: ["reddit_session", "token_v2"],
                domSelectors: ["postLinks": "a[href*='/comments/']"]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .snapchat,
                publicCapabilities: ["Public Spotlight & profile link discovery"],
                sessionAuthenticatedCapabilities: ["Snapchat Web (web.snapchat.com) session messaging"],
                officialAPICapabilities: ["Snapchat Marketing API"],
                prohibitedOrRestrictedCapabilities: ["Automated bulk messaging without active mobile device confirmation"],
                authDetectionCookieNames: ["sc-a-session"],
                domSelectors: ["chatInput": "div[role='textbox']"]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .imo,
                publicCapabilities: ["Phone contact list preparation & formatting"],
                sessionAuthenticatedCapabilities: ["Imo Web session messaging"],
                officialAPICapabilities: [],
                prohibitedOrRestrictedCapabilities: ["No official public web automation API provided by Imo"],
                authDetectionCookieNames: ["imo_session"],
                domSelectors: [:]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .google,
                publicCapabilities: [
                    "Google Contacts vCard (.vcf) generation & Google Maps public business discovery"
                ],
                sessionAuthenticatedCapabilities: [
                    "Google Messages Web (messages.google.com/web) SMS dispatch after QR pairing",
                    "Google Maps review navigation in authenticated session"
                ],
                officialAPICapabilities: ["Google People API & Google Places API"],
                prohibitedOrRestrictedCapabilities: ["Sending SMS without paired Android phone on Google Messages Web"],
                authDetectionCookieNames: ["SID", "HSID", "SSID"],
                domSelectors: ["smsInput": "textarea[placeholder*='Text message']"]
            ),
            SocialPlatformCapabilityMatrix(
                platform: .autoPoint,
                publicCapabilities: ["Portal reachability check (like4like.org, getlike.io)"],
                sessionAuthenticatedCapabilities: ["Interactive point exchange session inside isolated WKWebView"],
                officialAPICapabilities: [],
                prohibitedOrRestrictedCapabilities: ["Bypassing Cloudflare Turnstile / anti-bot on point exchange portals"],
                authDetectionCookieNames: ["PHPSESSID"],
                domSelectors: [:]
            )
        ]

        var map: [MarketingPlatform: SocialPlatformCapabilityMatrix] = [:]
        for item in list { map[item.platform] = item }
        self.platformMatrices = map
    }

    /// Classifies any MarketingToolCard into one of the 4 regulatory capability tiers.
    public nonisolated func classifyToolCapability(_ tool: MarketingToolCard) -> SocialCapabilityTier {
        if tool.platform == .sendEmails || tool.platform == .otherTools || tool.platform == .dashboard {
            return .publicNoAuth
        }
        if tool.id == "pin_accounts" {
            return .prohibitedOrUnavailable
        }
        let sub = tool.subMenu.lowercased()
        if sub.contains("extract") || sub.contains("search") || sub.contains("analysis") || sub.contains("top growing") {
            return .publicNoAuth
        }
        if tool.id.contains("api") {
            return .officialAPIAuth
        }
        return .userSessionAuth
    }

    /// Generates the real JavaScript DOM automation & extraction payload injected into `WKWebView` for a given platform and operation.
    public nonisolated func buildDOMAutomationScript(for platform: MarketingPlatform, operation: String, messageText: String = "") -> String {
        let matrix = platformMatrices[platform]
        let postSel = matrix?.domSelectors["postLinks"] ?? "a[href]"
        let commentSel = matrix?.domSelectors["commentBox"] ?? matrix?.domSelectors["commentInput"] ?? "textarea, div[contenteditable='true']"
        let escapedMsg = messageText
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")

        return """
        (function() {
            const op = "\(operation)";
            const title = document.title || "";
            const url = window.location.href || "";
            const cookies = document.cookie || "";
            const links = Array.from(document.querySelectorAll("\(postSel)"))
                .map(a => ({ href: a.href, text: (a.innerText || a.textContent || "").trim() }))
                .filter(x => x.href && x.href.startsWith("http"));

            // Auto-scroll to trigger lazy pagination if extracting
            if (op.toLowerCase().includes("extract") || op.toLowerCase().includes("search")) {
                window.scrollBy(0, 900);
            }

            let actionStatus = "DOM_INSPECTED";
            if ("\(escapedMsg)".length > 0) {
                const inputEl = document.querySelector("\(commentSel)");
                if (inputEl) {
                    inputEl.focus();
                    if (inputEl.tagName === "TEXTAREA" || inputEl.tagName === "INPUT") {
                        inputEl.value = "\(escapedMsg)";
                        inputEl.dispatchEvent(new Event('input', { bubbles: true }));
                    } else {
                        inputEl.innerText = "\(escapedMsg)";
                        inputEl.dispatchEvent(new Event('input', { bubbles: true }));
                    }
                    actionStatus = "MESSAGE_INJECTED_IN_DOM";
                } else {
                    actionStatus = "AUTH_OR_SELECTOR_REQUIRED";
                }
            }

            return JSON.stringify({
                title: title,
                url: url,
                cookieLength: cookies.length,
                discoveredCount: links.length,
                items: links.slice(0, 50),
                actionStatus: actionStatus
            });
        })();
        """
    }

    /// Inspects whether a BrowserInstance currently holds an authenticated session for the given platform.
    public func checkSessionAuthenticationState(platform: MarketingPlatform, instance: BrowserInstance) async -> (isAuthenticated: Bool, matchedCookies: [String]) {
        guard let matrix = platformMatrices[platform] else { return (false, []) }
        let store = instance.webView.configuration.websiteDataStore.httpCookieStore
        let allCookies = await store.allCookies()
        let names = Set(allCookies.map(\.name))
        let matched = matrix.authDetectionCookieNames.filter { names.contains($0) }
        return (!matched.isEmpty, matched)
    }
}
