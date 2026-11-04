import Foundation

public enum ToolCatalog {
    // MARK: - Complete Marketing Tool Cards (Exact match with Videos V01 to V10)
    public static let allMarketingTools: [MarketingToolCard] = [
        // ================= FACEBOOK =================
        MarketingToolCard(
            id: "fb_login", platform: .facebook, subMenu: "Login",
            titleAr: "تسجيل الدخول على الفيس بوك", titleEn: "Facebook Account Login",
            descAr: "أدخل بيانات حسابك على فيسبوك للمتابعة (يرجى اختيار اللغة العربية لحسابك قبل البدء)",
            descEn: "Sign in to your Facebook account to use extraction and page tools",
            buttonAr: "تسجيل الدخول", buttonEn: "Sign In",
            iconName: "person.badge.key.fill", columns: ["Email / Phone", "Proxy", "State"],
            panelKind: .loginForm, defaultUrl: "https://www.facebook.com/login"
        ),
        MarketingToolCard(
            id: "fb_search", platform: .facebook, subMenu: "Search",
            titleAr: "البحث واستخراج الصفحات والمجموعات", titleEn: "Search Pages & Groups",
            descAr: "إضافة كلمة مفتاحية والبحث عن الصفحات أو المجموعات واستخراج معرفاتها",
            descEn: "Search Facebook Pages or Groups by keyword and extract their IDs",
            buttonAr: "بحث واستخراج", buttonEn: "Search & Extract",
            iconName: "magnifyingglass.circle.fill", columns: ["Name", "ID"],
            defaultUrl: "https://www.facebook.com/search/groups"
        ),
        // Facebook > Extract (11 tools from V01 04:12 & V02 01:48)
        MarketingToolCard(
            id: "fb_ext_reactions", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج المعجبين بالمنشورات", titleEn: "Extract Post Reactors & Likers",
            descAr: "استخراج معرف منشورات الصفحات والمجموعات وكل المتفاعلين على المنشورات",
            descEn: "Extract post IDs from Pages/Groups and all users who reacted or shared",
            buttonAr: "استخراج معجبين المنشورات", buttonEn: "Extract Post Reactors",
            iconName: "hand.thumbsup.fill", columns: ["Posts ID", "State", "Users IDS"],
            panelKind: .facebookPostReactions, defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ext_comments", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج التعليقات بالمنشورات", titleEn: "Extract Post Comments",
            descAr: "استخراج جميع العملاء المتفاعلين في التعليقات على المنشورات مع إعدادات التوقف المؤقت",
            descEn: "Extract all users who commented on target posts with periodic pause settings",
            buttonAr: "استخراج التعليقات", buttonEn: "Extract Comments",
            iconName: "text.bubble.fill", columns: ["IDS", "State", "Comment", "User ID"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ext_comm_numbers", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج أرقام الهاتف من التعليقات", titleEn: "Extract Phone Numbers from Comments",
            descAr: "استخراج أرقام الهواتف من التعليقات للعملاء المهتمين (يدعم المنشورات والريلز Reels)",
            descEn: "Parse comments on posts and Facebook Reels to extract phone numbers",
            buttonAr: "أرقام التعليقات", buttonEn: "Comment Numbers",
            iconName: "phone.down.circle.fill", columns: ["Post ID", "Phone Number", "User Name", "Comment"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ext_page_senders", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج مراسلين صفحتك", titleEn: "Extract Page Inbox Messengers",
            descAr: "استخراج جميع مراسلي صفحتك التجارية بشرط أن تكون أدمن فيها",
            descEn: "Extract all customers who messaged your Facebook Business Page",
            buttonAr: "مراسلين صفحتك", buttonEn: "Page Messengers",
            iconName: "tray.full.fill", columns: ["ID - Link", "Gender", "Other Info", "Name"],
            defaultUrl: "https://business.facebook.com/latest/inbox"
        ),
        MarketingToolCard(
            id: "fb_ext_public_pages", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج البيانات العامة للصفحات", titleEn: "Extract Public Page Data",
            descAr: "استخراج بيانات الصفحات التجارية أو البيانات الديموغرافية العامة (واتساب، بريد، تصنيف، موقع)",
            descEn: "Extract WhatsApp, Email, Category, and Website from Facebook Pages",
            buttonAr: "استخراج من الصفحات", buttonEn: "Extract Pages Data",
            iconName: "building.2.fill", columns: ["ID", "Name", "Whatsapp", "Email", "Category", "Website"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ext_page_reviews", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج التقييمات من الصفحات", titleEn: "Extract Page Reviews",
            descAr: "استخراج جميع العملاء المهتمين الذين قاموا بعمل تقييمات على الصفحة التجارية",
            descEn: "Extract all users who posted reviews on a target Facebook Page",
            buttonAr: "استخراج العملاء", buttonEn: "Extract Reviewers",
            iconName: "star.bubble.fill", columns: ["User", "Name", "Review", "Review Type"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ext_client_public", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج البيانات العامة للعملاء", titleEn: "Extract Public Client Profiles",
            descAr: "استخراج البيانات العامة للعملاء المهتمين دفعة واحدة (العمل، الدراسة، الإقامة، المنشأ)",
            descEn: "Extract public demographic fields for a list of Facebook Client IDs",
            buttonAr: "البيانات العامة", buttonEn: "Public Profile Data",
            iconName: "person.text.rectangle.fill", columns: ["Client Id", "Name", "Work", "Study", "Studied at", "Live in", "From"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ext_friends", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج الأصدقاء وتقسيمهم", titleEn: "Extract & Segment Friends",
            descAr: "استخراج جميع الأصدقاء من الحساب أو الحسابات الشخصية وتقسيمهم بالاسم أو البلد",
            descEn: "Extract all friends from personal accounts and filter/segment them",
            buttonAr: "استخراج الأصدقاء", buttonEn: "Extract Friends",
            iconName: "person.2.fill", columns: ["Member", "Name", "Location", "State"],
            defaultUrl: "https://www.facebook.com/friends"
        ),
        MarketingToolCard(
            id: "fb_ext_group_members", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج أعضاء المجموعات", titleEn: "Extract Group Members",
            descAr: "استخراج جميع أعضاء المجموعات المنضم لها أو العامة دفعة واحدة مع حفظ مباشر",
            descEn: "Extract members from any joined or public Facebook group to file",
            buttonAr: "استخراج الأعضاء", buttonEn: "Extract Members",
            iconName: "person.3.fill", columns: ["User ID", "Name", "Group ID", "Profile Link"],
            defaultUrl: "https://www.facebook.com/groups"
        ),
        MarketingToolCard(
            id: "fb_ext_top_fans", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج الداعمين من الصفحات", titleEn: "Extract Page Top Fans",
            descAr: "استخراج المتفاعلين والداعمين من الصفحات التجارية",
            descEn: "Extract top fans and active supporters from Facebook Pages",
            buttonAr: "استخراج الداعمين", buttonEn: "Extract Top Fans",
            iconName: "crown.fill", columns: ["User ID", "Name", "Badge", "Page ID"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ext_account_messengers", platform: .facebook, subMenu: "Extract",
            titleAr: "استخراج مراسلين الحساب والمجموعات من المنشورات", titleEn: "Extract Personal Messengers & Post Groups",
            descAr: "استخراج جميع مراسلي الحساب الشخصي واستخراج المجموعات المشترك فيها من منشورات",
            descEn: "Extract personal Messenger contacts and groups discovered via posts",
            buttonAr: "استخراج المراسلين", buttonEn: "Extract Messengers",
            iconName: "message.badge.filled.fill", columns: ["Name", "Group / User ID", "Link"],
            defaultUrl: "https://www.facebook.com/messages"
        ),
        // Facebook > Analysis (7 tools from V02 02:40)
        MarketingToolCard(
            id: "fb_ana_segment", platform: .facebook, subMenu: "Analysis",
            titleAr: "تقسيم العملاء حسب المعرف", titleEn: "Segment Clients by ID",
            descAr: "تقسيم العملاء حسب المعرف الخاص بهم وحذف المكرر بضغطة واحدة",
            descEn: "Split and deduplicate client ID lists by criteria",
            buttonAr: "تقسيم العملاء", buttonEn: "Segment Clients",
            iconName: "scissors", columns: ["ID", "Name", "Filtered Segment"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ana_target_groups", platform: .facebook, subMenu: "Analysis",
            titleAr: "استخراج واستهداف المجموعات", titleEn: "Extract & Filter Joined Groups",
            descAr: "استخراج جميع المجموعات المنضم لها وتصفيتهم بالاهتمامات والكلمات المفتاحية",
            descEn: "Extract all joined groups and filter them by niche keywords",
            buttonAr: "استخراج المجموعات", buttonEn: "Extract Joined Groups",
            iconName: "line.3.horizontal.decrease.circle.fill", columns: ["Name", "Group ID", "Members"],
            defaultUrl: "https://www.facebook.com/groups/joins"
        ),
        MarketingToolCard(
            id: "fb_ana_users_to_ids", platform: .facebook, subMenu: "Analysis",
            titleAr: "تحويل (USERS) إلى (IDS)", titleEn: "Convert Usernames to Numeric IDs",
            descAr: "تحويل كافة العملاء من اليوزر إلى أيديهات دفعة واحدة",
            descEn: "Batch convert Facebook usernames into numeric UIDs",
            buttonAr: "تحويل العملاء", buttonEn: "Convert Users to IDs",
            iconName: "number.square.fill", columns: ["User", "User_ID"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ana_group_analyzer", platform: .facebook, subMenu: "Analysis",
            titleAr: "تحليل المجموعات (مفتوحة النشر / بموافقة الأدمن)", titleEn: "Group Structure & Publishing Analyzer",
            descAr: "استخراج جميع المجموعات المنضم لها وتحليل (النوع، العدد، البيع، النشر المباشر بدون موافقة)",
            descEn: "Analyze groups for Public/Private, Selling format, Member count, and Open Publishing",
            buttonAr: "تحليل المجموعات", buttonEn: "Analyze Groups",
            iconName: "chart.bar.doc.horizontal.fill", columns: ["Name", "Type", "Number", "Link", "ID", "Sell", "Publishing"],
            panelKind: .facebookGroupAnalyzer, defaultUrl: "https://www.facebook.com/groups"
        ),
        MarketingToolCard(
            id: "fb_ana_post_details", platform: .facebook, subMenu: "Analysis",
            titleAr: "استخراج تفاصيل المنشورات", titleEn: "Extract Post Details",
            descAr: "استخراج كافة تفاصيل المنشورات دفعة واحدة (إعجابات، تعليقات، مشاركات، محتوى)",
            descEn: "Extract full engagement metrics and text content for a list of posts",
            buttonAr: "تفاصيل المنشورات", buttonEn: "Post Details",
            iconName: "doc.text.magnifyingglass", columns: ["ID", "Date", "Likes", "Comments", "Shares", "Content", "Post Link"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ana_competitor_posts", platform: .facebook, subMenu: "Analysis",
            titleAr: "تحليل منشورات المجموعات أو الصفحات", titleEn: "Analyze Group & Page Posts",
            descAr: "تحليل منشورات المجموعات والصفحات للحصول على نقاط القوة والضعف",
            descEn: "Audit competitor Page and Group posts to identify top-performing content",
            buttonAr: "تحليل المنشورات", buttonEn: "Analyze Posts",
            iconName: "waveform.path.ecg.rectangle.fill", columns: ["Post Id", "Content", "Reacts", "Comment", "Shares", "Time", "Link", "Type"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_ana_urls_to_ids", platform: .facebook, subMenu: "Analysis",
            titleAr: "تحويل الروابط إلى (IDS)", titleEn: "Convert Post/Group URLs to IDs",
            descAr: "تحويل كافة روابط المنشورات أو المجموعات إلى أيديهات",
            descEn: "Convert full Facebook URLs into numeric Post/Group/Profile IDs",
            buttonAr: "تحويل الروابط", buttonEn: "Convert Links",
            iconName: "link.badge.plus", columns: ["Link", "Post_ID"],
            defaultUrl: "https://www.facebook.com"
        ),
        // Facebook > Marketing (7 tools from V02 03:44)
        MarketingToolCard(
            id: "fb_mkt_group_single", platform: .facebook, subMenu: "Marketing",
            titleAr: "النشر في المجموعات", titleEn: "Publish in Joined Groups",
            descAr: "النشر على جميع المجموعات المنضم لها دفعة واحدة (يدعم منشور بيع ومنشور مجهول الهوية)",
            descEn: "Publish multimedia posts across joined groups with Selling & Anonymous options",
            buttonAr: "النشر في المجموعات", buttonEn: "Publish in Groups",
            iconName: "megaphone.fill", columns: ["IDS", "Time", "State"],
            defaultUrl: "https://www.facebook.com/groups"
        ),
        MarketingToolCard(
            id: "fb_mkt_group_multi", platform: .facebook, subMenu: "Marketing",
            titleAr: "النشر في المجموعات بحسابات متعددة", titleEn: "Multi-Account Group Publisher",
            descAr: "النشر على جميع المجموعات العامة أو المنضم لها دفعة واحدة بحسابات أو صفحات متعددة",
            descEn: "Publish across hundreds of groups using multiple accounts or Business Pages",
            buttonAr: "النشر في المجموعات", buttonEn: "Multi-Account Publish",
            iconName: "person.3.sequence.fill", columns: ["IDS", "Time", "State", "Group Status"],
            defaultUrl: "https://mbasic.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_mkt_msg_pages", platform: .facebook, subMenu: "Marketing",
            titleAr: "إرسال رسائل إلى الصفحات التجارية", titleEn: "Message Business Pages",
            descAr: "إرسال الرسائل الترويجية إلى الصفحات العامة والتجارية بحسابات متعددة",
            descEn: "Send promotional messages directly to Facebook Business & Public Pages",
            buttonAr: "إرسال إلى الصفحات التجارية", buttonEn: "Message Pages",
            iconName: "building.columns.fill", columns: ["ID Or Users", "State", "Time"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_mkt_share_post", platform: .facebook, subMenu: "Marketing",
            titleAr: "مشاركة المنشور في المجموعات", titleEn: "Share Page Post to Groups",
            descAr: "مشاركة منشور الصفحة على المجموعات المنضم لها أو العامة بحسابات متعددة",
            descEn: "Share a Facebook Page post across multiple groups with preview",
            buttonAr: "مشاركة المنشور", buttonEn: "Share Post",
            iconName: "arrowshape.turn.up.right.circle.fill", columns: ["IDS", "Time", "State"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_mkt_page_reviews", platform: .facebook, subMenu: "Marketing",
            titleAr: "تقييمات على الصفحات", titleEn: "Post Reviews on Pages",
            descAr: "أداة لعمل تقييمات على الصفحات في حال السماح لأصحابها بعمل تقييم",
            descEn: "Post automated reviews and recommendations on Facebook Pages",
            buttonAr: "تقييمات على الصفحات", buttonEn: "Review Pages",
            iconName: "star.leadinghalf.filled", columns: ["Page ID", "State", "Time"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_mkt_auto_publish", platform: .facebook, subMenu: "Marketing",
            titleAr: "النشر التلقائي على الصفحات الشخصية", titleEn: "Auto-Publish & Image Scraper",
            descAr: "استخراج الصور بكلمة مفتاحية والنشر التلقائي للمنشورات بالحسابات الشخصية",
            descEn: "Scrape images by keyword and auto-publish posts across personal profiles",
            buttonAr: "النشر التلقائي", buttonEn: "Auto Publish",
            iconName: "photo.on.rectangle.angled", columns: ["Description", "Link", "Section Name", "State"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_mkt_auto_reply", platform: .facebook, subMenu: "Marketing",
            titleAr: "الرد التلقائي على التعليقات", titleEn: "Auto-Reply to Post Comments",
            descAr: "الرد التلقائي على كل تعليقات المنشورات وإرسال رسالة خاصة للمتفاعل",
            descEn: "Monitor post comments and auto-reply in comments + private Messenger DM",
            buttonAr: "الرد التلقائي", buttonEn: "Auto Reply",
            iconName: "arrow.uturn.left.circle.fill", columns: ["User", "Name", "Date", "Comment", "State"],
            defaultUrl: "https://www.facebook.com"
        ),
        // Facebook > Broadcast, Pages, Mention, Other Tools (V03 01:32-04:52)
        MarketingToolCard(
            id: "fb_brd_direct", platform: .facebook, subMenu: "Broadcast",
            titleAr: "إرسال رسائل إلى العملاء", titleEn: "Send Direct Messages to Clients",
            descAr: "أرسل رسائل إلى العملاء والأصدقاء باستخدام أيديهات أو يوزرات بحسابات متعددة",
            descEn: "Send private Messenger campaigns to UIDs or usernames via multiple accounts",
            buttonAr: "إرسال رسائل", buttonEn: "Send Messages",
            iconName: "paperplane.fill", columns: ["ID Or Users", "State", "Time"],
            defaultUrl: "https://www.facebook.com/messages"
        ),
        MarketingToolCard(
            id: "fb_brd_chat_group", platform: .facebook, subMenu: "Broadcast",
            titleAr: "إضافة العملاء إلى مجموعة شات (USERS)", titleEn: "Add Clients to Messenger Chat Group",
            descAr: "إضافة العملاء في جروب شات من خلال اليوزرات دفعة واحدة وإرسال رسالة",
            descEn: "Create a Messenger group chat with target clients and broadcast your offer",
            buttonAr: "مجموعة شات", buttonEn: "Chat Group",
            iconName: "bubble.left.and.bubble.right.fill", columns: ["ID Or Users", "Time", "State"],
            defaultUrl: "https://www.facebook.com/messages"
        ),
        MarketingToolCard(
            id: "fb_pages_retarget", platform: .facebook, subMenu: "Pages",
            titleAr: "إعادة مراسلة جميع عملاء صفحتك", titleEn: "Retarget Page Inbox Customers",
            descAr: "إرسال حملة ترويجية لجميع العملاء الذين راسلوا صفحتك التجارية مسبقاً",
            descEn: "Send multimedia follow-up campaigns to all existing Page inbox threads",
            buttonAr: "مراسلة عملاء الصفحة", buttonEn: "Message Page Clients",
            iconName: "flag.2.crossed.fill", columns: ["IDS", "Name", "Time", "State"],
            defaultUrl: "https://business.facebook.com/latest/inbox"
        ),
        MarketingToolCard(
            id: "fb_mention_posts", platform: .facebook, subMenu: "Mention",
            titleAr: "إشارة العملاء في المنشورات أو التعليقات", titleEn: "Mention Clients in Posts & Comments",
            descAr: "عمل منشن أو إشارة للعملاء المهتمين داخل المنشور أو في التعليقات",
            descEn: "Tag extracted client UIDs inside post bodies or comment threads",
            buttonAr: "بدء الإشارة", buttonEn: "Start Mention",
            iconName: "at", columns: ["ID", "Time", "State"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_oth_join_like", platform: .facebook, subMenu: "Other Tools",
            titleAr: "أدوات إضافية (انضمام للمجموعات / إعجاب بالصفحات)", titleEn: "Join Groups, Leave Groups & Like Pages",
            descAr: "أدوات إضافية مثل عمل إعجاب للصفحات والانضمام أو مغادرة المجموعات وقبول الطلبات",
            descEn: "Batch join/leave groups, like pages, and accept friend requests",
            buttonAr: "أدوات إضافية", buttonEn: "Additional Tools",
            iconName: "plus.rectangle.on.folder.fill", columns: ["Group / Page ID", "Action", "State"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_oth_add_friends", platform: .facebook, subMenu: "Other Tools",
            titleAr: "إرسال طلبات صداقة إلى العملاء", titleEn: "Send Friend Requests",
            descAr: "إرسال طلب صداقة للعملاء المهتمين دفعة واحدة مع إعدادات التوقف المؤقت",
            descEn: "Send automated friend requests to target UIDs with periodic pause",
            buttonAr: "طلبات صداقة", buttonEn: "Friend Requests",
            iconName: "person.badge.plus", columns: ["ID", "State"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_oth_remove_friends", platform: .facebook, subMenu: "Other Tools",
            titleAr: "حذف الأصدقاء ودعوة المتفاعلين", titleEn: "Remove Friends & Invite to Group/Page",
            descAr: "حذف جميع الأصدقاء دفعة واحدة أو دعوة المتفاعلين لعمل إعجاب بالصفحة والانضمام للمجموعة",
            descEn: "Batch unfriend inactive contacts or invite reactors to like your Page",
            buttonAr: "حذف ودعوة الأصدقاء", buttonEn: "Manage Friends & Invites",
            iconName: "person.crop.circle.badge.minus", columns: ["Friend ID", "Action", "State"],
            defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_oth_engagement_farm", platform: .facebook, subMenu: "Other Tools",
            titleAr: "مزرعة التفاعل (Engagement Farm)", titleEn: "Facebook Engagement Farm",
            descAr: "مزرعة التفاعل الخاصة من خلالها تقوم بعمل تفاعل (إعجاب، حب، تعليق، مشاركة، حفظ) بكل حساباتك",
            descEn: "Orchestrate multi-account reactions, comments, shares, page likes, and post saves",
            buttonAr: "مزرعة التفاعل", buttonEn: "Engagement Farm",
            iconName: "hand.thumbsup.circle.fill", columns: ["Links", "Time", "State"],
            panelKind: .facebookEngagementFarm, defaultUrl: "https://www.facebook.com"
        ),
        MarketingToolCard(
            id: "fb_oth_delete_posts", platform: .facebook, subMenu: "Other Tools",
            titleAr: "حذف المنشورات وموافقة أو رفض المنشورات", titleEn: "Delete Posts & Moderate Group Posts",
            descAr: "حذف جميع المنشورات من الصفحة أو المجموعة وموافقة أو رفض جميع المنشورات المعلقة",
            descEn: "Bulk delete Page/Group posts and auto-approve or decline pending group posts",
            buttonAr: "حذف ومراجعة المنشورات", buttonEn: "Delete & Moderate Posts",
            iconName: "trash.circle.fill", columns: ["Post ID", "Action", "State"],
            defaultUrl: "https://www.facebook.com"
        ),

        // ================= WHATSAPP (V04 00:00 - 03:20) =================
        MarketingToolCard(
            id: "wa_flt_standard", platform: .whatsapp, subMenu: "Filter",
            titleAr: "تصفية العملاء", titleEn: "Standard WhatsApp Number Filter",
            descAr: "تصفية العملاء الموجودين بدون الحفظ في جهات الاتصال",
            descEn: "Filter phone numbers into Activated and UnActivated without saving contacts",
            buttonAr: "تصفية العملاء", buttonEn: "Filter Numbers",
            iconName: "checkmark.shield.fill", columns: ["Phone Number", "Activated", "UnActivated"],
            panelKind: .whatsappDualFilter, browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_flt_new", platform: .whatsapp, subMenu: "Filter",
            titleAr: "تصفية العملاء الجديدة", titleEn: "Fast VCF / Contact WhatsApp Filter",
            descAr: "تصفية العملاء الموجودين بشرط الحفظ في جهات الاتصال (60 رقم / دقيقة)",
            descEn: "High-speed 3-column filter (Pending / Active / Inactive) with independent exports",
            buttonAr: "التصفية الجديدة", buttonEn: "New Fast Filter",
            iconName: "bolt.shield.fill", columns: ["قيد الانتظار (Pending)", "يعمل (Active)", "غير مفعل (Inactive)"],
            panelKind: .whatsappTripleFilter, browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_ext_by_links", platform: .whatsapp, subMenu: "Extract",
            titleAr: "استخراج الأعضاء من خلال روابط المجموعات", titleEn: "Extract Group Members via Invite Links",
            descAr: "استخراج الأعضاء من خلال روابط المجموعات دفعة واحدة",
            descEn: "Auto-join WhatsApp group invite links and extract all member phone numbers",
            buttonAr: "استخراج الأعضاء", buttonEn: "Extract by Links",
            iconName: "link.circle.fill", columns: ["Links", "State", "Extracted Phone"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_ext_no_links", platform: .whatsapp, subMenu: "Extract",
            titleAr: "استخراج الأعضاء بدون روابط المجموعات", titleEn: "Extract Members from Joined Groups",
            descAr: "استخراج الأعضاء من خلال اسم المجموعة أو استخراج جميع المجموعات ويجب أن تكون منضم لها",
            descEn: "Extract members from any joined group by name or direct DOM inspection",
            buttonAr: "استخراج الأعضاء", buttonEn: "Extract Joined Group",
            iconName: "person.3.fill", columns: ["Mobile Phone Number", "Group Name"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_ext_correspondents", platform: .whatsapp, subMenu: "Extract",
            titleAr: "استخراج مراسلين الواتس آب وجهات الاتصال (API)", titleEn: "Extract Chats, Contacts & Archived (API)",
            descAr: "استخراج جميع عملائي المراسلين واستخراج جميع جهات الاتصال والدردشات المؤرشفة",
            descEn: "Extract all chat correspondents, saved contacts, and archived chats via API",
            buttonAr: "استخراج المراسلين", buttonEn: "Extract Chats & Contacts",
            iconName: "bubble.left.and.text.bubble.right.fill", columns: ["Number", "Name", "Source"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_ext_social_groups", platform: .whatsapp, subMenu: "Extract",
            titleAr: "استخراج المجموعات من البحث", titleEn: "Extract WhatsApp Groups from Social Media",
            descAr: "استخراج روابط المجموعات من منصات التواصل الاجتماعي (Twitter / Facebook / Instagram / LinkedIn)",
            descEn: "Discover chat.whatsapp.com invite links across social networks by keyword",
            buttonAr: "استخراج المجموعات", buttonEn: "Search Group Links",
            iconName: "globe.americas.fill", columns: ["Group Invite Link", "Platform", "Keyword"],
            browserModalType: .sessionList, defaultUrl: "https://www.google.com"
        ),
        MarketingToolCard(
            id: "wa_ext_analyze_links", platform: .whatsapp, subMenu: "Extract",
            titleAr: "تحليل روابط المجموعات", titleEn: "Analyze WhatsApp Group Links",
            descAr: "فحص روابط المجموعات التي تعمل والتي لا تعمل واستخراج اسم المجموعة",
            descEn: "Verify invite links and extract active group names vs revoked links",
            buttonAr: "تحليل المجموعات", buttonEn: "Analyze Group Links",
            iconName: "checkmark.seal.fill", columns: ["Groups", "Name", "Status"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_post_groups", platform: .whatsapp, subMenu: "Post In Groups",
            titleAr: "النشر في المجموعات من أرقام متعددة", titleEn: "Multi-Number Group Publisher",
            descAr: "النشر على مجموعات الواتس آب من أرقام متعددة مع التبديل بينهم",
            descEn: "Publish text and media across WhatsApp groups rotating multiple numbers",
            buttonAr: "النشر في المجموعات", buttonEn: "Post In Groups",
            iconName: "megaphone.fill", columns: ["Groups", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_brd_api_single", platform: .whatsapp, subMenu: "Broadcast",
            titleAr: "الإرسال الفردي API الجديدة", titleEn: "Single Send (New API & Multi-Channel)",
            descAr: "إرسال رسائل إلى العملاء المهتمين بصورة أو ألبوم صور بدون حفظ جهات الاتصال",
            descEn: "Direct API sending to unsaved numbers with photo/album and multi-number rotation",
            buttonAr: "الإرسال الجديدة", buttonEn: "Single API Send",
            iconName: "paperplane.circle.fill", columns: ["Numbers", "Name", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_brd_contacts", platform: .whatsapp, subMenu: "Broadcast",
            titleAr: "الإرسال لجهات الاتصال", titleEn: "Send to Saved Contacts (20/min)",
            descAr: "إرسال رسائل إلى العملاء لجهات الاتصال فقط بسرعة عالية",
            descEn: "High-speed campaign sending to contacts synced in your address book",
            buttonAr: "الإرسال لجهات الاتصال", buttonEn: "Send to Contacts",
            iconName: "person.crop.rectangle.stack.fill", columns: ["Numbers", "Name", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_brd_forward5", platform: .whatsapp, subMenu: "Broadcast",
            titleAr: "الإرسال الجديد (إعادة توجيه الرسائل)", titleEn: "New High-Speed Forward Send (35/min)",
            descAr: "إعادة توجيه الرسائل إلى العملاء المهتمين (5 عملاء في الضغطة الواحدة)",
            descEn: "Forward multi-bubble messages to 5 recipients per batch at up to 35/min",
            buttonAr: "الإرسال الجديد", buttonEn: "New Fast Send",
            iconName: "arrowshape.Bounce.right.fill", columns: ["Numbers", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_brd_add_to_group", platform: .whatsapp, subMenu: "Broadcast",
            titleAr: "إضافة العملاء بالمجموعة", titleEn: "Add Clients to Existing Group",
            descAr: "إضافة العملاء في المجموعات دفعة واحدة (250 شخص في 3 دقائق)",
            descEn: "Bulk add extracted phone numbers into an existing WhatsApp group",
            buttonAr: "إضافة العملاء بالمجموعة", buttonEn: "Add to Group",
            iconName: "person.badge.plus", columns: ["Numbers", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),
        MarketingToolCard(
            id: "wa_brd_create_brand_group", platform: .whatsapp, subMenu: "Broadcast",
            titleAr: "إنشاء مجموعة وإضافة العملاء", titleEn: "Create Brand Groups & Broadcast",
            descAr: "إنشاء مجموعات باسم نشاطك التجاري وإضافة العملاء في المجموعات دفعة واحدة",
            descEn: "Automatically create branded sub-groups, add clients, and post your campaign",
            buttonAr: "إنشاء وإضافة العملاء", buttonEn: "Create & Add Clients",
            iconName: "plus.bubble.fill", columns: ["Numbers", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://web.whatsapp.com"
        ),

        // ================= INSTAGRAM (V04 03:32 - V05 03:16) =================
        MarketingToolCard(
            id: "ig_login", platform: .instagram, subMenu: "Login",
            titleAr: "تسجيل الدخول على انستجرام", titleEn: "Instagram Login",
            descAr: "يرجى اختيار اللغة الإنجليزية لمتصفحك الشخصي قبل البدء على البرنامج",
            descEn: "Sign in to Instagram (English UI recommended for DOM selectors)",
            buttonAr: "تسجيل الدخول", buttonEn: "Sign In",
            iconName: "camera.circle.fill", columns: ["Username", "Proxy", "State"],
            panelKind: .loginForm, defaultUrl: "https://www.instagram.com/accounts/login/"
        ),
        MarketingToolCard(
            id: "ig_ext_followers", platform: .instagram, subMenu: "Extract",
            titleAr: "استخراج المتابعين والمتابعون الجديدة", titleEn: "Extract Followers & Following (New + Old)",
            descAr: "استخراج المتابعين والمتابعون للمنافسين وجميع الأنشطة التجارية مع إعدادات التوقف المؤقت",
            descEn: "Extract all followers or following of any competitor profile with pause controls",
            buttonAr: "الاستخراج", buttonEn: "Extract Followers",
            iconName: "person.2.circle.fill", columns: ["Username", "Full Name", "Status"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_ext_likes_comments", platform: .instagram, subMenu: "Extract",
            titleAr: "استخراج الإعجابات والتعليقات من المنشورات", titleEn: "Extract Post Likes & Comments",
            descAr: "استخراج المتفاعلين من الإعجابات والتعليقات من المنشورات",
            descEn: "Extract all users who liked or commented on target Instagram posts/Reels",
            buttonAr: "الإعجابات والتعليقات", buttonEn: "Likes & Comments",
            iconName: "heart.text.square.fill", columns: ["Username", "Interaction", "Status"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_ext_dm_senders", platform: .instagram, subMenu: "Extract",
            titleAr: "استخراج مراسلين الحساب الشخصي", titleEn: "Extract Direct Message Correspondents",
            descAr: "استخراج جميع مراسلي نشاطك التجاري أو حسابك الشخصي في الانبوكس",
            descEn: "Scrape all users from your Instagram Direct inbox for retargeting",
            buttonAr: "استخراج المراسلين", buttonEn: "Extract Inbox",
            iconName: "envelope.open.fill", columns: ["User_ID", "Username"],
            defaultUrl: "https://www.instagram.com/direct/inbox/"
        ),
        MarketingToolCard(
            id: "ig_ext_hashtags_places", platform: .instagram, subMenu: "Extract",
            titleAr: "استخراج اليوزرات من الهاشتاجات والأماكن (API)", titleEn: "Extract Users from Hashtags & Places (API)",
            descAr: "استخراج البيانات من خلال الهاشتاجات والأماكن (الأكسبلور) مدينة أو دولة أو منطقة",
            descEn: "Extract active users by niche hashtag or geographic location",
            buttonAr: "استخراج", buttonEn: "Extract by Niche",
            iconName: "number.circle.fill", columns: ["Username", "Source Hashtag/Location", "State"],
            defaultUrl: "https://www.instagram.com/explore/"
        ),
        MarketingToolCard(
            id: "ig_ext_posts", platform: .instagram, subMenu: "Extract",
            titleAr: "استخراج المنشورات", titleEn: "Extract Profile Posts",
            descAr: "استخراج روابط جميع المنشورات للمنافسين وجميع الأنشطة التجارية",
            descEn: "Extract all post and Reel URLs from any Instagram profile",
            buttonAr: "استخراج المنشورات", buttonEn: "Extract Posts",
            iconName: "square.grid.3x3.fill", columns: ["Posts", "Likes", "Comments"],
            defaultUrl: "https://www.instagram.com"
        ),
        // Instagram > Marketing (7 tools from V05 00:08)
        MarketingToolCard(
            id: "ig_mkt_general_data", platform: .instagram, subMenu: "Marketing",
            titleAr: "تحليل البيانات العامة (AI)", titleEn: "AI Demographic & Contact Analyzer",
            descAr: "تحليل بيانات وسلوكيات العملاء أو المنافسين دفعة واحدة (الهاتف، الإيميل، المتابعين)",
            descEn: "Extract phone, email, bio, posts, followers, and following count via AI",
            buttonAr: "(AI) بدء التحليل", buttonEn: "Start AI Analysis",
            iconName: "brain.head.profile", columns: ["ID/User", "Phone number", "Email", "Posts", "Followers", "Following"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_mkt_hashtag_media", platform: .instagram, subMenu: "Marketing",
            titleAr: "استخراج الهاشتاج وحفظ الصور", titleEn: "Hashtag Analyzer & Image Downloader",
            descAr: "استخراج جميع الهاشتاجات بكلمات مفتاحية وتنزيل الصور المرتبطة بها",
            descEn: "Discover top hashtags by keyword and batch-download hashtag photos",
            buttonAr: "استخراج الهاشتاج", buttonEn: "Extract Hashtags",
            iconName: "photo.stack.fill", columns: ["Hashtag Links", "Hashtag", "Posts"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_mkt_engagement_farm", platform: .instagram, subMenu: "Marketing",
            titleAr: "مزرعة التفاعل (Instagram Farm)", titleEn: "Instagram Engagement Farm",
            descAr: "مزرعة التفاعل الخاصة من خلالها تقوم بعمل تفاعل (إعجاب، تعليق، حفظ، ريبوست، متابعة)",
            descEn: "Multi-account Like, Comment, Bookmark, Repost, and Follow on target posts",
            buttonAr: "مزرعة التفاعل", buttonEn: "Engagement Farm",
            iconName: "flame.fill", columns: ["Links", "State"],
            panelKind: .instagramEngagementFarm, defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_mkt_influencers", platform: .instagram, subMenu: "Marketing",
            titleAr: "استخراج الأشخاص المشهورين", titleEn: "Extract Influencers & Celebrities",
            descAr: "استخراج الأشخاص المشهورين بجميع الاهتمامات أو في دولة معينة",
            descEn: "Find verified influencers and top creators by niche and country",
            buttonAr: "الأشخاص المشهورين", buttonEn: "Extract Influencers",
            iconName: "star.square.fill", columns: ["User Links", "Username", "Followers", "Category"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_mkt_monitor_competitors", platform: .instagram, subMenu: "Marketing",
            titleAr: "متابعة المنافسين أو الأنشطة التجارية لحظة بلحظة", titleEn: "Real-Time Competitor Monitor",
            descAr: "متابعة منشورات المنافسين والأنشطة التجارية لحظة بلحظة والتفاعل/المنشن الفوري",
            descEn: "Monitor competitor profiles in real time and auto-comment/DM on new posts",
            buttonAr: "متابعة المنشورات", buttonEn: "Monitor Competitors",
            iconName: "eye.circle.fill", columns: ["Profile Link", "@Username", "State"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_mkt_publish_posts", platform: .instagram, subMenu: "Marketing",
            titleAr: "نشر المنشورات أو الريلز", titleEn: "Publish Posts & Reels",
            descAr: "نشر المنشورات أو الريلز على كل حسابات الانستجرام دفعة واحدة",
            descEn: "Publish photos, videos, or Reels across all connected Instagram accounts",
            buttonAr: "نشر المنشورات", buttonEn: "Publish Posts/Reels",
            iconName: "plus.square.on.square.fill", columns: ["Image / Video", "Caption", "State"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_mkt_delete_posts", platform: .instagram, subMenu: "Marketing",
            titleAr: "حذف المنشورات", titleEn: "Bulk Delete Instagram Posts",
            descAr: "حذف كل المنشورات من حساب الانستجرام دفعة واحدة",
            descEn: "Delete all posts from connected Instagram accounts in one click",
            buttonAr: "حذف المنشورات", buttonEn: "Delete Posts",
            iconName: "trash.fill", columns: ["Links", "Time", "State"],
            defaultUrl: "https://www.instagram.com"
        ),
        // Instagram > Follow (4 tools from V05 01:28)
        MarketingToolCard(
            id: "ig_flw_multi", platform: .instagram, subMenu: "Follow",
            titleAr: "عمل متابعة من حسابات متعددة (AI)", titleEn: "Multi-Account Follow / Unfollow (AI)",
            descAr: "عمل متابعة أو إلغاء متابعة للعملاء المستهدفين من حسابات متعددة دفعة واحدة",
            descEn: "Follow or Unfollow target users across multiple accounts (New AI + Old tool)",
            buttonAr: "متابعة", buttonEn: "Multi-Account Follow",
            iconName: "person.badge.plus", columns: ["User", "User Id", "State"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_flw_single", platform: .instagram, subMenu: "Follow",
            titleAr: "عمل متابعة من حساب واحد (Follow V2)", titleEn: "Direct Modal Follow (Single Account)",
            descAr: "عمل متابعة مباشرة من قائمة المتابعين لأي نشاط تجاري من حساب واحد",
            descEn: "Click Follow sequentially inside an open competitor Followers modal",
            buttonAr: "متابعة", buttonEn: "Direct Follow",
            iconName: "person.crop.circle.badge.checkmark", columns: ["Target Account", "Count", "State"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_flw_list", platform: .instagram, subMenu: "Follow",
            titleAr: "عمل متابعة من قائمة حسابات (مع بروكسي)", titleEn: "Follow from Account List (with Proxy)",
            descAr: "عمل متابعة من قائمة حسابات (إيميل، باسورد، بروكسي) دفعة واحدة",
            descEn: "Execute Follow campaigns from a credentials + proxy list",
            buttonAr: "المتابعة الجديدة", buttonEn: "List Follow",
            iconName: "list.bullet.rectangle.portrait.fill", columns: ["Email", "Password", "Proxy", "@Users", "State"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_flw_suggestions", platform: .instagram, subMenu: "Follow",
            titleAr: "متابعة من الاقتراحات", titleEn: "Auto-Follow from Instagram Suggestions",
            descAr: "عمل متابعة من الاقتراحات بحسابات متعددة دفعة واحدة (يدعم متابعة سريعة)",
            descEn: "Automatically follow accounts recommended by Instagram's algorithm",
            buttonAr: "متابعة", buttonEn: "Follow Suggestions",
            iconName: "sparkles.rectangle.stack.fill", columns: ["Suggested User", "Time", "State"],
            defaultUrl: "https://www.instagram.com/explore/people/"
        ),
        // Instagram > Mention (2 tools from V05 02:04) & Broadcast (6 tools from V05 02:36)
        MarketingToolCard(
            id: "ig_men_multi", platform: .instagram, subMenu: "Mention",
            titleAr: "إشارة إلى العملاء من حسابات متعددة (AI)", titleEn: "Multi-Account Comment Mention (AI)",
            descAr: "عمل منشن إلى العملاء من حسابات متعددة دفعة واحدة",
            descEn: "Mention extracted users in post comments across multiple browser sessions",
            buttonAr: "منشن", buttonEn: "Multi-Account Mention",
            iconName: "at.circle.fill", columns: ["@Username", "Time", "Status"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_men_list", platform: .instagram, subMenu: "Mention",
            titleAr: "إشارة إلى العملاء من قائمة حسابات", titleEn: "Mention Clients from Account/Proxy List",
            descAr: "عمل منشن إلى العملاء بقائمة حسابات وبروكسي دفعة واحدة",
            descEn: "Mention target users using an Email/Password/Proxy account list",
            buttonAr: "منشن", buttonEn: "Account List Mention",
            iconName: "at.badge.plus", columns: ["Email", "Password", "Proxy", "@Users", "State"],
            defaultUrl: "https://www.instagram.com"
        ),
        MarketingToolCard(
            id: "ig_brd_new_follow_dm", platform: .instagram, subMenu: "Broadcast",
            titleAr: "الإرسال الجديد (متابعة + إرسال فردي)", titleEn: "New Send (Auto-Follow + Direct Message)",
            descAr: "إرسال رسائل مباشرة ومتابعة إلى العملاء المهتمين بحسابات متعددة",
            descEn: "Follow target user and immediately send a personalized Direct Message",
            buttonAr: "الإرسال الجديد", buttonEn: "Follow & Send DM",
            iconName: "paperplane.fill", columns: ["@Username", "Time", "State"],
            defaultUrl: "https://www.instagram.com/direct/inbox/"
        ),
        MarketingToolCard(
            id: "ig_brd_group_dm", platform: .instagram, subMenu: "Broadcast",
            titleAr: "الإرسال الجماعي", titleEn: "Instagram Group DM Broadcast",
            descAr: "إرسال رسائل جماعية إلى العملاء المهتمين بحسابات متعددة",
            descEn: "Create group conversations in Instagram Direct and broadcast messages",
            buttonAr: "الإرسال الجماعي", buttonEn: "Group DM",
            iconName: "person.3.fill", columns: ["@Username", "Time", "State"],
            defaultUrl: "https://www.instagram.com/direct/inbox/"
        ),
        MarketingToolCard(
            id: "ig_brd_single_dm", platform: .instagram, subMenu: "Broadcast",
            titleAr: "الإرسال الفردي (وإعادة استهداف المراسلين بـ ID)", titleEn: "Single DM & Inbox ID Retargeting",
            descAr: "إرسال رسائل مباشرة إلى العملاء المهتمين أو إعادة مراسلة الانبوكس بالـ ID",
            descEn: "Send 1-to-1 DMs by username or retarget existing inbox threads by ID",
            buttonAr: "الإرسال الفردي", buttonEn: "Single DM",
            iconName: "bubble.right.fill", columns: ["@Username - ID", "Time", "State"],
            defaultUrl: "https://www.instagram.com/direct/inbox/"
        ),
        MarketingToolCard(
            id: "ig_brd_list_dm", platform: .instagram, subMenu: "Broadcast",
            titleAr: "الإرسال الجديد من قائمة حسابات", titleEn: "Send DMs from Account/Proxy List",
            descAr: "إرسال رسائل مباشرة ومتابعة إلى العملاء المهتمين بقائمة حسابات وبروكسي",
            descEn: "Send Direct Messages using an imported Email/Password/Proxy list",
            buttonAr: "الإرسال الجديد", buttonEn: "List DM Send",
            iconName: "list.bullet.indent", columns: ["Email", "Password", "Proxy", "@Users", "Time", "State"],
            defaultUrl: "https://www.instagram.com/direct/inbox/"
        ),
        MarketingToolCard(
            id: "ig_brd_share_post", platform: .instagram, subMenu: "Broadcast",
            titleAr: "مشاركة المنشور في الرسائل (متعدد أو قائمة)", titleEn: "Share Post into Client DMs",
            descAr: "مشاركة المنشورات إلى رسائل العملاء بحسابات متعددة أو بقائمة حسابات",
            descEn: "Share an Instagram post directly into recipients' Direct Message inboxes",
            buttonAr: "مشاركة المنشور", buttonEn: "Share Post to DM",
            iconName: "square.and.arrow.up.fill", columns: ["@Username", "Time", "State"],
            defaultUrl: "https://www.instagram.com"
        ),

        // ================= THREADS (V05 03:20 - 03:48) =================
        MarketingToolCard(
            id: "th_extract", platform: .threads, subMenu: "Extract",
            titleAr: "استخراج المتابعين والمتفاعلين من ثريدز", titleEn: "Extract Threads Followers & Commenters",
            descAr: "استخراج العملاء المتفاعلين والمتابعين من منصة Threads مع إعدادات التوقف المؤقت",
            descEn: "Extract followers and commenters from Threads profiles and posts",
            buttonAr: "بدء الاستخراج", buttonEn: "Extract Threads Users",
            iconName: "at.circle.fill", columns: ["UserName", "State"],
            defaultUrl: "https://www.threads.net"
        ),
        MarketingToolCard(
            id: "th_mention", platform: .threads, subMenu: "Mention",
            titleAr: "إشارة للعملاء في تعليقات ثريدز", titleEn: "Threads Comment Mention",
            descAr: "عمل إشارة أو منشن للعملاء المهتمين في تعليقات منشورات Threads",
            descEn: "Mention target usernames inside Threads reply chains",
            buttonAr: "بدء الحملة التسويقية", buttonEn: "Start Mention Campaign",
            iconName: "at", columns: ["Users", "State"],
            defaultUrl: "https://www.threads.net"
        ),
        MarketingToolCard(
            id: "th_marketing", platform: .threads, subMenu: "Marketing",
            titleAr: "الحملة التسويقية الشاملة على ثريدز", titleEn: "Threads Engagement & Marketing",
            descAr: "تنفيذ عمليات المنشن والتعليق والإعجاب وإعادة النشر بحسابات متعددة",
            descEn: "Run multi-account Mention, Reply, Like, and Repost campaigns on Threads",
            buttonAr: "بدء الحملة التسويقية", buttonEn: "Start Campaign",
            iconName: "bolt.horizontal.circle.fill", columns: ["User Name", "Time", "State"],
            defaultUrl: "https://www.threads.net"
        ),

        // ================= TWITTER / X (V05 03:52 - V07 02:16) =================
        MarketingToolCard(
            id: "tw_login", platform: .twitter, subMenu: "Login",
            titleAr: "تسجيل الدخول على تويتر (X)", titleEn: "X (Twitter) Login",
            descAr: "أدخل بيانات حسابك على تويتر للمتابعة مع دعم البروكسي ونظام حفظ الحسابات",
            descEn: "Sign in to X/Twitter with optional proxy and bulk account saver",
            buttonAr: "تسجيل الدخول", buttonEn: "Sign In",
            iconName: "bird.fill", columns: ["Username / Email", "Proxy", "State"],
            panelKind: .loginForm, defaultUrl: "https://x.com/i/flow/login"
        ),
        MarketingToolCard(
            id: "tw_ext_search_followers", platform: .twitter, subMenu: "Extract",
            titleAr: "استخراج من البحث والمتابعون", titleEn: "Extract from Search & Followers",
            descAr: "استخراج الأنشطة التجارية من البحث واستخراج المتابعين مع إعدادات التوقف المؤقت",
            descEn: "Extract users matching search queries or following target X accounts",
            buttonAr: "استخراج", buttonEn: "Extract Users",
            iconName: "magnifyingglass", columns: ["Link / @User", "Name", "State"],
            defaultUrl: "https://x.com/explore"
        ),
        MarketingToolCard(
            id: "tw_ext_tweets_delete", platform: .twitter, subMenu: "Extract",
            titleAr: "استخراج التغريدات أو حذفها", titleEn: "Extract or Bulk Delete Tweets",
            descAr: "استخراج جميع التغريدات للمنافسين أو حذف التغريدات من حسابي",
            descEn: "Scrape all tweets from any profile or bulk delete tweets from your account",
            buttonAr: "استخراج التغريدات", buttonEn: "Extract / Delete Tweets",
            iconName: "doc.richtext.fill", columns: ["Tweets", "Time", "State"],
            defaultUrl: "https://x.com"
        ),
        MarketingToolCard(
            id: "tw_ext_trends", platform: .twitter, subMenu: "Extract",
            titleAr: "استخراج التريندات العالمية", titleEn: "Global Trending Topics Extractor",
            descAr: "استخراج جميع التريندات اللحظية والجديدة لكل دول العالم على مدار اليوم",
            descEn: "Extract live and emerging X Trending Topics across all countries",
            buttonAr: "استخراج التريندات", buttonEn: "Extract Trends",
            iconName: "number.square.fill", columns: ["Hashtag", "Country", "Time", "Tweet Count", "Hashtag Link"],
            panelKind: .twitterTrendsExtractor, defaultUrl: "https://trends24.in"
        ),
        MarketingToolCard(
            id: "tw_ext_tweet_reactors", platform: .twitter, subMenu: "Extract",
            titleAr: "استخراج المتفاعلين من التغريدة والمتابعين (AI)", titleEn: "AI Tweet Interactors & Followers Extractor",
            descAr: "استخراج جميع المتفاعلين على التغريدات وكافة المتابعين بالذكاء الاصطناعي",
            descEn: "Extract users who replied, liked, or retweeted a target post via AI",
            buttonAr: "استخراج من التغريدة", buttonEn: "Extract Interactors",
            iconName: "sparkles", columns: ["ID With Tweet", "Username", "State"],
            defaultUrl: "https://x.com"
        ),
        MarketingToolCard(
            id: "tw_ext_demographics", platform: .twitter, subMenu: "Extract",
            titleAr: "استخراج البيانات الديموغرافية العامة للعملاء", titleEn: "Extract X Profile Demographics",
            descAr: "استخراج الاسم، الهاتف، البريد، الموقع، الدولة، عدد المتابعين وتاريخ الانضمام",
            descEn: "Extract bio phone, email, website, location, followers, and join date",
            buttonAr: "استخراج", buttonEn: "Extract Demographics",
            iconName: "person.text.rectangle", columns: ["@User", "Name", "Phone", "Email", "Website", "Location", "Following", "Followers", "Joined In"],
            defaultUrl: "https://x.com"
        ),
        MarketingToolCard(
            id: "tw_scheduled", platform: .twitter, subMenu: "Scheduled",
            titleAr: "جدولة التغريدات", titleEn: "Schedule Multi-Account Tweets",
            descAr: "برمجة وجدولة التغريدات بالصور والتاريخ والوقت الدقيق",
            descEn: "Schedule tweets with text and images by exact date and time",
            buttonAr: "إضافة التغريدة", buttonEn: "Schedule Tweet",
            iconName: "calendar.badge.clock", columns: ["Tweets", "Scheduled Date/Time", "State"],
            panelKind: .twitterScheduled, defaultUrl: "https://x.com"
        ),
        MarketingToolCard(
            id: "tw_mention", platform: .twitter, subMenu: "Mention",
            titleAr: "إشارة للعملاء في التغريدات أو التعليقات", titleEn: "Mention Clients in Tweets & Replies",
            descAr: "عمل منشن للعملاء المهتمين في التغريدات أو الردود بحسابات متعددة",
            descEn: "Tag extracted @usernames inside tweets or reply threads",
            buttonAr: "بدء الإشارة", buttonEn: "Start Mention",
            iconName: "at", columns: ["@Username", "Time", "State"],
            defaultUrl: "https://x.com"
        ),
        MarketingToolCard(
            id: "tw_broadcast", platform: .twitter, subMenu: "Broadcast",
            titleAr: "إرسال رسائل مباشرة ومشاركة تغريدات في الخاص", titleEn: "X Direct Message & Tweet Share",
            descAr: "إرسال رسائل فردية وجماعية ومشاركة التغريدات إلى العملاء برسائل مباشرة",
            descEn: "Send individual/group DMs or share tweets directly into user inboxes",
            buttonAr: "إرسال رسائل", buttonEn: "Send X DMs",
            iconName: "envelope.badge.fill", columns: ["@Username", "Time", "State"],
            defaultUrl: "https://x.com/messages"
        ),
        MarketingToolCard(
            id: "tw_follow", platform: .twitter, subMenu: "Follow",
            titleAr: "متابعة وإلغاء متابعة العملاء (والمتابعة السريعة)", titleEn: "Multi-Account Follow & Fast Follow",
            descAr: "متابعة العملاء المستهدفين أو إلغاء المتابعة مع خيار المتابعة السريعة",
            descEn: "Follow or Unfollow target X accounts across multiple sessions",
            buttonAr: "بدء المتابعة", buttonEn: "Start Follow",
            iconName: "person.badge.plus", columns: ["@Username", "Time", "State"],
            defaultUrl: "https://x.com"
        ),
        MarketingToolCard(
            id: "tw_mkt_hashtags_farm", platform: .twitter, subMenu: "Marketing",
            titleAr: "تسويق ورفع الهاشتاجات ومزرعة التفاعل وفحص الحسابات", titleEn: "Raise Hashtags, Top Search Farm & Account Checker",
            descAr: "رفع الهاشتاجات للتريند، النشر التلقائي، فحص الحسابات وفحص الرسائل المفتوحة ومزرعة التفاعل",
            descEn: "Trend hashtags, boost tweets to Top Search, and verify active/DM-open accounts",
            buttonAr: "أدوات تسويق تويتر", buttonEn: "Open X Marketing Tool",
            iconName: "chart.line.uptrend.xyaxis", columns: ["Account / Target", "Status", "DM Open"],
            panelKind: .twitterAccountChecker, defaultUrl: "https://x.com"
        ),
        MarketingToolCard(
            id: "tw_retweet", platform: .twitter, subMenu: "Retweet",
            titleAr: "عمل ريتويت بحسابات متعددة أو بقائمة حسابات", titleEn: "Mass Retweet & Quote Tweet",
            descAr: "مشاركة التغريدات دفعة واحدة مع تعليق أو بدون تعليق أو ريتويت سريع",
            descEn: "Execute mass Retweets or Quote Tweets across sessions or proxy account lists",
            buttonAr: "عمل ريتويت", buttonEn: "Start Retweet",
            iconName: "arrow.2.squarepath", columns: ["Retweet URL", "State", "Account"],
            defaultUrl: "https://x.com"
        ),

        // ================= X PLUS (V07 04:28 - 05:00) =================
        MarketingToolCard(
            id: "xplus_monitor", platform: .xPlus, subMenu: "Monitor & Engage",
            titleAr: "مراقبة الحسابات لحظة بلحظة والرد الآلي بالذكاء الاصطناعي", titleEn: "X Plus Real-Time Account Monitor & AI Auto-Reply",
            descAr: "مراقبة الحسابات والأنشطة التجارية لحظة بلحظة والتفاعل والمنشن بالذكاء الاصطناعي فور نشر أي تغريدة",
            descEn: "Monitor target X accounts second-by-second and trigger instant AI replies & engagement",
            buttonAr: "بدء العملية", buttonEn: "Start Real-Time Monitor",
            iconName: "Cpu.fill", columns: ["Target Account", "Detected Tweet", "AI Action", "Time"],
            defaultUrl: "https://x.com"
        ),
        MarketingToolCard(
            id: "xplus_schedule_trends", platform: .xPlus, subMenu: "Scheduled & Hashtags",
            titleAr: "إنشاء وجدولة التغريدات بالهاشتاج لرفع التريندات", titleEn: "X Plus Industrial Hashtag Trend Booster",
            descAr: "تجهيز وجدولة التغريدات بالهاشتاج من مئات أو آلاف الحسابات لرفع الترندات",
            descEn: "Orchestrate high-volume hashtag tweets and scheduled campaigns",
            buttonAr: "بدء النشر أو الجدولة", buttonEn: "Launch Trend Campaign",
            iconName: "flame.circle.fill", columns: ["Tweets", "Hashtag", "Scheduled Time", "State"],
            panelKind: .twitterScheduled, defaultUrl: "https://x.com"
        ),

        // ================= LINKEDIN (V07 02:28 - V08 00:24) =================
        MarketingToolCard(
            id: "li_login", platform: .linkedIn, subMenu: "Login",
            titleAr: "تسجيل الدخول على لينكد إن", titleEn: "LinkedIn Login",
            descAr: "أدخل بيانات حسابك على لينكد إن للمتابعة (يرجى اختيار اللغة العربية لحسابك قبل البدء)",
            descEn: "Sign in to LinkedIn to unlock B2B scraping and outreach tools",
            buttonAr: "تسجيل الدخول", buttonEn: "Sign In",
            iconName: "briefcase.circle.fill", columns: ["Email", "State"],
            panelKind: .loginForm, defaultUrl: "https://www.linkedin.com/login"
        ),
        MarketingToolCard(
            id: "li_search", platform: .linkedIn, subMenu: "Search",
            titleAr: "البحث واستخراج العملاء وإرسال طلبات تواصل", titleEn: "Search B2B Prospects & Send Invitations",
            descAr: "البحث بكلمة مفتاحية واستخراج الروابط وإرسال طلبات تواصل مباشرة",
            descEn: "Search LinkedIn profiles by keyword/title and send connection requests",
            buttonAr: "بدء الاستخراج", buttonEn: "Search & Connect",
            iconName: "magnifyingglass.circle.fill", columns: ["Name", "Links", "Current", "Operation Time"],
            defaultUrl: "https://www.linkedin.com/search/results/people/"
        ),
        MarketingToolCard(
            id: "li_ext_connections", platform: .linkedIn, subMenu: "Extract",
            titleAr: "استخراج الزملاء وبيانات الزملاء (11 عمود)", titleEn: "Extract Connections & Full Contact Info (11 Columns)",
            descAr: "استخراج جميع بيانات الديموغرافية للزملاء (الاسم، الهاتف، الإيميل، العنوان، الوظيفة، الدولة، التعليم)",
            descEn: "Scrape detail/contact-info modals for 1st-degree connections into 11 columns",
            buttonAr: "بيانات الزملاء", buttonEn: "Extract Contact Info",
            iconName: "person.text.rectangle.fill",
            columns: ["Link", "Name", "Phone", "Email", "Address", "Job", "Country", "Education", "Status", "Contact", "About"],
            defaultUrl: "https://www.linkedin.com/mynetwork/invite-connect/connections/"
        ),
        MarketingToolCard(
            id: "li_ext_companies_unis", platform: .linkedIn, subMenu: "Extract",
            titleAr: "استخراج بيانات الشركات والجامعات وأعضاء المجموعات", titleEn: "Extract Companies, Universities & Group Members",
            descAr: "استخراج جميع البيانات الديموغرافية للشركات والجامعات وأعضاء المجموعات والمتفاعلين",
            descEn: "Scrape company/university pages (Phone, Website, Size, Founded) and group members",
            buttonAr: "الجامعات والشركات", buttonEn: "Extract B2B Entities",
            iconName: "building.2.crop.circle.fill",
            columns: ["Name", "Phone", "Email", "Website", "Industry", "Company Size", "Headquarters", "Founded"],
            defaultUrl: "https://www.linkedin.com/search/results/companies/"
        ),
        MarketingToolCard(
            id: "li_ext_search_engines", platform: .linkedIn, subMenu: "Extract",
            titleAr: "استخراج إيميلات وبيانات من محركات البحث", titleEn: "Extract LinkedIn Emails via Search Engines",
            descAr: "استخراج إيميلات العملاء بالاهتمام والدولة للينكد إن من محركات البحث (Google / Bing / Yahoo)",
            descEn: "Extract verified emails and profiles by niche, country, and email domain",
            buttonAr: "محركات البحث", buttonEn: "Search Engine Extract",
            iconName: "at.badge.plus", columns: ["Name", "Email", "Phone", "LinkedIn URL", "Country"],
            defaultUrl: "https://www.google.com"
        ),
        MarketingToolCard(
            id: "li_marketing", platform: .linkedIn, subMenu: "Marketing",
            titleAr: "أدوات التسويق والنشر ومزرعة التفاعل على لينكد إن", titleEn: "LinkedIn Groups, Invitations, Engagement Farm & Posts",
            descAr: "انضمام للمجموعات، إرسال طلب تواصل، متابعة الشركات، مزرعة التفاعل، النشر وجدولة المنشورات",
            descEn: "Join groups, send invitations, follow companies, run engagement farm, and publish posts",
            buttonAr: "بدء التسويق", buttonEn: "Open LinkedIn Marketing",
            iconName: "megaphone.circle.fill", columns: ["Target / Link", "Action", "Time", "State"],
            defaultUrl: "https://www.linkedin.com/feed/"
        ),
        MarketingToolCard(
            id: "li_broadcast", platform: .linkedIn, subMenu: "Broadcast",
            titleAr: "إرسال رسائل إلى العملاء بحسابات متعددة", titleEn: "Multi-Account LinkedIn Direct Messaging",
            descAr: "إرسال رسائل إلى الزملاء والعملاء بحسابات متعددة وفواصل زمنية آمنة",
            descEn: "Send personalized messages to LinkedIn connections across multiple accounts",
            buttonAr: "بدء الإرسال", buttonEn: "Send LinkedIn Messages",
            iconName: "paperplane.fill", columns: ["Link", "Time", "State"],
            defaultUrl: "https://www.linkedin.com/messaging/"
        ),

        // ================= TELEGRAM & PREMIUM (V08 00:32 - 03:36) =================
        MarketingToolCard(
            id: "tg_ext_correspondents", platform: .telegram, subMenu: "Extract",
            titleAr: "استخراج مراسلين التليجرام وجهات الاتصال", titleEn: "Extract Telegram Correspondents & Contacts",
            descAr: "استخراج مراسلين حسابي وجهات الاتصال على التليجرام دفعة واحدة (ID + Access Hash + Phone)",
            descEn: "Extract all private chat correspondents and contacts via MTProto API",
            buttonAr: "استخراج المراسلين", buttonEn: "Extract Correspondents",
            iconName: "person.crop.circle.badge.clock", columns: ["ID", "Access Hash", "Name", "Phone", "User", "Status"],
            browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        MarketingToolCard(
            id: "tg_ext_group_members", platform: .telegram, subMenu: "Extract",
            titleAr: "استخراج أعضاء المجموعات (العامة والسرية)", titleEn: "Extract Telegram Group Members (Access Hash)",
            descAr: "استخراج جميع أعضاء المجموعات وتوزيع الاستخراج على عشرات الحسابات",
            descEn: "Extract group members (ID, Access Hash, Username, Phone) distributed across accounts",
            buttonAr: "استخراج الأعضاء", buttonEn: "Extract Group Members",
            iconName: "person.3.sequence.fill", columns: ["Account", "Extracted File", "Members Count", "Status"],
            panelKind: .telegramMemberExtractor, browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        MarketingToolCard(
            id: "tg_ext_search_links", platform: .telegram, subMenu: "Extract",
            titleAr: "استخراج الروابط من البحث وتحميل +20 ألف مجموعة", titleEn: "Search Telegram Links & 20K Groups Library",
            descAr: "استخراج روابط المجموعات والقنوات من منصات التواصل الاجتماعي وتحميل 20 ألف مجموعة",
            descEn: "Discover t.me links from social networks or load built-in directory of group links",
            buttonAr: "استخراج الروابط", buttonEn: "Extract Group Links",
            iconName: "link.circle.fill", columns: ["Group / Channel Link", "Category", "Platform"],
            browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        MarketingToolCard(
            id: "tg_add_users", platform: .telegram, subMenu: "Add User",
            titleAr: "إضافة ونقل العملاء إلى المجموعة والانضمام للمجموعات", titleEn: "Transfer Members to Group & Multi-Account Join",
            descAr: "إضافة العملاء من خلال Access Hash أو اليوزر أو الهاتف والانضمام للمجموعات بكل الحسابات",
            descEn: "Add/transfer extracted members into your group and auto-join groups with all sessions",
            buttonAr: "إضافة العملاء", buttonEn: "Add / Join Groups",
            iconName: "person.badge.plus", columns: ["Account", "Target Group", "Added Count", "Status"],
            browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        MarketingToolCard(
            id: "tg_change_profiles_2fa", platform: .telegram, subMenu: "Add User",
            titleAr: "تغيير بيانات الحسابات وتفعيل المصادقة الثنائية (2FA)", titleEn: "Bulk Profile Editor & 2FA Password Manager",
            descAr: "تغيير الاسم الأول والأخير والوصف واليوزر والصورة وتفعيل المصادقة الثنائية لكل الحسابات",
            descEn: "Batch update FirstName, LastName, Bio, Username, Avatar, and 2FA password",
            buttonAr: "تغيير البيانات / 2FA", buttonEn: "Update Profiles & 2FA",
            iconName: "lock.rotation", columns: ["FirstName", "LastName", "Bio", "Username", "State"],
            panelKind: .telegramProfileChanger, browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        MarketingToolCard(
            id: "tg_broadcast_all", platform: .telegram, subMenu: "Broadcast",
            titleAr: "إرسال الرسائل الجديدة والنشر في المجموعات", titleEn: "Telegram Mass Broadcast (AccessHash / Username / Phone / Groups)",
            descAr: "إرسال رسائل إلى العملاء المهتمين (الصورة مع النص) أو النشر في جميع المجموعات مع حفظ التقرير",
            descEn: "Send multimedia campaigns by AccessHash, Username, Phone, or Groups with Save Report",
            buttonAr: "إرسال الرسائل", buttonEn: "Start Telegram Broadcast",
            iconName: "paperplane.fill", columns: ["Account", "Target File / User", "Status"],
            panelKind: .telegramBroadcast, browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        MarketingToolCard(
            id: "tg_other_analyzer", platform: .telegram, subMenu: "Other Tools",
            titleAr: "تحليل المجموعات والقنوات", titleEn: "Telegram Group & Channel Link Analyzer",
            descAr: "تحليل الروابط لمعرفة الاسم والنوع (مجموعة أم قناة) وعدد الأعضاء والرابط",
            descEn: "Inspect t.me links to determine Name, Type (Group vs Channel), and Member Count",
            buttonAr: "بدء التحليل", buttonEn: "Analyze Telegram Links",
            iconName: "chart.bar.xaxis", columns: ["Name", "Type", "Number", "Link"],
            browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        // Telegram Premium (V08 03:20 - 03:36)
        MarketingToolCard(
            id: "tgp_hidden_members", platform: .telegramPremium, subMenu: "Hidden Members Extract",
            titleAr: "استخراج الأعضاء المخفيين (Hidden Members VIP)", titleEn: "Extract Hidden Group Members (VIP)",
            descAr: "استخراج الأعضاء وبياناتهم من المجموعات التي تفعل ميزة إخفاء الأعضاء",
            descEn: "Extract members and metadata from Telegram groups with Hidden Members enabled",
            buttonAr: "استخراج الأعضاء المخفيين", buttonEn: "Extract Hidden Members",
            iconName: "eye.slash.circle.fill", columns: ["ID", "Access Hash", "Username", "Phone", "Name"],
            browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        MarketingToolCard(
            id: "tgp_keyword_search", platform: .telegramPremium, subMenu: "Keyword Search",
            titleAr: "البحث عن المجموعات أو القنوات أو الدردشات بكلمات مفتاحية", titleEn: "Global Keyword Search for Groups & Channels",
            descAr: "البحث عن ملايين القنوات والمجموعات والدردشات في كل المجالات وتصديرها إلى CSV/Excel",
            descEn: "Search Telegram globally by keyword list and export Group Name + Username",
            buttonAr: "بدء البحث", buttonEn: "Search Telegram",
            iconName: "magnifyingglass.circle.fill", columns: ["Name", "Type", "Number", "Link"],
            browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),
        MarketingToolCard(
            id: "tgp_reactions", platform: .telegramPremium, subMenu: "Reactions & Transfer",
            titleAr: "التفاعل التلقائي على الرسائل ونقل الأعضاء", titleEn: "Auto-Reactions & Premium Member Transfer",
            descAr: "إمكانية التفاعل بالرموز التعبيرية على الرسائل في المجموعات والقنوات ونقل الأعضاء",
            descEn: "Send automated emoji reactions to group/channel posts and transfer members",
            buttonAr: "بدء التفاعل", buttonEn: "Start Reactions",
            iconName: "hand.thumbsup.fill", columns: ["Target Post / Group", "Reaction", "Account", "State"],
            browserModalType: .telegramMTProto, defaultUrl: "https://web.telegram.org"
        ),

        // ================= SNAPCHAT & IMO (V08 03:40 - 04:44) =================
        MarketingToolCard(
            id: "snap_broadcast", platform: .snapchat, subMenu: "Broadcast",
            titleAr: "استخراج الأصدقاء وإرسال رسائل سناب شات", titleEn: "Snapchat Friends Extractor & Mass Sender",
            descAr: "استخراج كل الأصدقاء والعملاء المهتمين وإرسال رسائل ترويجية وصور وجهات اتصال واتساب",
            descEn: "Extract Snapchat Web friends and send text, images, and clickable WhatsApp contact cards",
            buttonAr: "بدء إرسال الرسائل", buttonEn: "Extract & Send Snap",
            iconName: "bell.badge.fill", columns: ["Username", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://web.snapchat.com"
        ),
        MarketingToolCard(
            id: "imo_sender", platform: .imo, subMenu: "Sender",
            titleAr: "استخراج جهات الاتصال وإرسال رسائل Imo", titleEn: "Imo Contact Extractor & Messenger",
            descAr: "استخراج جهات الاتصال وإرسال الرسائل الترويجية على منصة Imo",
            descEn: "Extract Imo contacts and broadcast promotional messages with media",
            buttonAr: "بدء الإرسال", buttonEn: "Start Imo Sender",
            iconName: "message.and.waveform.fill", columns: ["Phone", "Time", "State"],
            browserModalType: .cookiesAndProxy, defaultUrl: "https://web.imo.im"
        ),

        // ================= PINTEREST (V09 00:00 - 01:36) =================
        MarketingToolCard(
            id: "pin_login", platform: .pinterest, subMenu: "Login",
            titleAr: "تسجيل الدخول على بنترست", titleEn: "Pinterest Login",
            descAr: "أدخل بيانات حسابك على بنترست للمتابعة",
            descEn: "Sign in to your Pinterest account",
            buttonAr: "تسجيل الدخول", buttonEn: "Sign In",
            iconName: "pin.circle.fill", columns: ["Email", "State"],
            panelKind: .loginForm, defaultUrl: "https://www.pinterest.com/login/"
        ),
        MarketingToolCard(
            id: "pin_search", platform: .pinterest, subMenu: "Search",
            titleAr: "البحث واستخراج البوردات والأشخاص ومتابعتهم", titleEn: "Search Pinterest Boards & People",
            descAr: "البحث بكلمة مفتاحية واستخراج البوردات والمتابعين وعمل متابعة تلقائية",
            descEn: "Search Pinterest boards and profiles by keyword with direct auto-follow",
            buttonAr: "بدء الاستخراج", buttonEn: "Search & Follow",
            iconName: "magnifyingglass", columns: ["Name", "Boards", "Followers", "Pin Count", "Link", "State"],
            defaultUrl: "https://www.pinterest.com/search/pins/"
        ),
        MarketingToolCard(
            id: "pin_accounts", platform: .pinterest, subMenu: "Accounts",
            titleAr: "إنشاء حسابات ترويجية على بنترست", titleEn: "Automated Pinterest Account Creator",
            descAr: "توليد وإنشاء حسابات ترويجية جديدة على بنترست تلقائياً",
            descEn: "Automatically generate and register promotional Pinterest accounts",
            buttonAr: "بدء الإنشاء", buttonEn: "Create Accounts",
            iconName: "person.crop.circle.badge.plus", columns: ["Email", "Password"],
            panelKind: .pinterestAccountCreator, defaultUrl: "https://www.pinterest.com"
        ),
        MarketingToolCard(
            id: "pin_extract", platform: .pinterest, subMenu: "Extract",
            titleAr: "استخراج من البورد أو المتابعين والمتابعون", titleEn: "Extract Users from Boards & Followers",
            descAr: "استخراج العملاء المهتمين من البورد أو المتابعين للأنشطة التجارية دفعة واحدة",
            descEn: "Extract user profiles from Pinterest boards or competitor followers",
            buttonAr: "استخراج المتابعين", buttonEn: "Extract Pinterest Users",
            iconName: "person.2.fill", columns: ["@Username", "Name", "Followers", "Following"],
            defaultUrl: "https://www.pinterest.com"
        ),
        MarketingToolCard(
            id: "pin_broadcast", platform: .pinterest, subMenu: "Broadcast",
            titleAr: "إرسال رسائل ترويجية على بنترست", titleEn: "Pinterest Direct Message Sender",
            descAr: "إرسال رسائل ترويجية بشكل احترافي للعملاء المستهدفين على بنترست",
            descEn: "Send promotional messages to extracted Pinterest usernames",
            buttonAr: "بدء إرسال الرسائل", buttonEn: "Send Pinterest Messages",
            iconName: "paperplane.fill", columns: ["Username", "State"],
            defaultUrl: "https://www.pinterest.com"
        ),
        MarketingToolCard(
            id: "pin_follow", platform: .pinterest, subMenu: "Follow",
            titleAr: "متابعة وإلغاء متابعة العملاء على بنترست", titleEn: "Pinterest Auto-Follow / Unfollow",
            descAr: "متابعة أو إلغاء متابعة العملاء المستهدفين بحسابات متعددة",
            descEn: "Follow or Unfollow Pinterest profiles across connected accounts",
            buttonAr: "بدء المتابعة", buttonEn: "Start Follow",
            iconName: "person.badge.plus", columns: ["Username", "State"],
            defaultUrl: "https://www.pinterest.com"
        ),
        MarketingToolCard(
            id: "pin_marketing", platform: .pinterest, subMenu: "Marketing",
            titleAr: "تنزيل الصور وإعادة النشر التلقائي على البورد", titleEn: "Pin Downloader & Auto-Pin Publisher",
            descAr: "تنزيل الصور من البحث أو الرابط وإعادة نشرها تلقائياً بعنوان ووصف ورابط على البورد",
            descEn: "Download pins by keyword/URL and auto-publish pins with custom title, link, and board",
            buttonAr: "بدء النشر التلقائي", buttonEn: "Download & Publish Pins",
            iconName: "pin.fill", columns: ["Title", "Description", "Link", "Board", "State"],
            defaultUrl: "https://www.pinterest.com/pin-builder/"
        ),

        // ================= SEND EMAILS (V09 01:44 - 02:28) =================
        MarketingToolCard(
            id: "email_smtp_wizard", platform: .sendEmails, subMenu: "SMTP Campaign",
            titleAr: "إرسال حملات البريد الإلكتروني (SMTP Multi-Account)", titleEn: "Multi-Account SMTP Email Marketing (4-Step Wizard)",
            descAr: "الإرسال إلى آلاف العملاء بإيميلات متعددة مع دعم قوالب HTML المخصصة وقائمة جميع سيرفرات SMTP",
            descEn: "Send bulk emails rotating multiple SMTP accounts with Plain Text or Custom HTML templates",
            buttonAr: "Start Send Messages", buttonEn: "Start Send Messages",
            iconName: "envelope.badge.shield.half.filled.fill",
            columns: ["Email", "Password", "Count", "HOST", "PORT", "SSL"],
            panelKind: .smtpFourStepWizard, defaultUrl: "https://senderprov.com/en/blog/list-of-smtp-and-pop3-servers-en"
        ),

        // ================= GOOGLE (SMS, GOOGLE RATE, CONTACTS - V09 02:36 - 03:32) =================
        MarketingToolCard(
            id: "gg_sms", platform: .google, subMenu: "SMS",
            titleAr: "إرسال رسائل SMS عبر منصة جوجل", titleEn: "Google Messages Web SMS Sender",
            descAr: "إرسال رسائل نصية قصيرة SMS بالرموز التعبيرية لكل العملاء عبر رسائل جوجل",
            descEn: "Send SMS campaigns with emojis via paired Google Messages for Web sessions",
            buttonAr: "بدء الحملة التسويقية", buttonEn: "Start SMS Campaign",
            iconName: "bubble.left.fill", columns: ["Numbers", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://messages.google.com/web"
        ),
        MarketingToolCard(
            id: "gg_rate", platform: .google, subMenu: "Google Rate",
            titleAr: "عمل تقييمات على خرائط جوجل (Google Maps Reviews)", titleEn: "Google Maps Business Review Generator",
            descAr: "عمل تقييمات بالنجوم والتعليقات للأنشطة التجارية على خرائط جوجل من حسابات جوجل متعددة",
            descEn: "Post star ratings (1-5) and reviews on Google Maps business listings",
            buttonAr: "بدء التقييم", buttonEn: "Start Google Reviews",
            iconName: "map.fill", columns: ["Links", "State", "Time"],
            defaultUrl: "https://www.google.com/maps"
        ),
        MarketingToolCard(
            id: "gg_contacts", platform: .google, subMenu: "Contacts",
            titleAr: "تجهيز وفلترة أرقام جهات اتصال جوجل", titleEn: "Google Contacts Formatter & Cleaner",
            descAr: "إضافة وتنسيق أرقام الهواتف لتصديرها ومزامنتها مع جهات اتصال جوجل",
            descEn: "Format and clean raw phone lists for seamless Google Contacts import",
            buttonAr: "بدء المعالجة", buttonEn: "Process Contacts",
            iconName: "person.crop.Square.filled.and.at.rectangle", columns: ["Input Phone", "Formatted Phone"],
            defaultUrl: "https://contacts.google.com"
        ),

        // ================= VK (V09 03:36 - 04:08) =================
        MarketingToolCard(
            id: "vk_login", platform: .vk, subMenu: "Login",
            titleAr: "تسجيل الدخول على في كا (VK)", titleEn: "VKontakte (VK) Login",
            descAr: "أدخل بيانات حسابك على VK للمتابعة",
            descEn: "Sign in to your VK account",
            buttonAr: "تسجيل الدخول", buttonEn: "Sign In",
            iconName: "person.2.square.stack.fill", columns: ["Email / Phone", "State"],
            panelKind: .loginForm, defaultUrl: "https://vk.com"
        ),
        MarketingToolCard(
            id: "vk_search", platform: .vk, subMenu: "Search",
            titleAr: "البحث عن الأشخاص على VK", titleEn: "VK People Search",
            descAr: "إضافة الكلمات المفتاحية واستخراج الأشخاص المهتمين",
            descEn: "Search VK users by keyword, city, and interest",
            buttonAr: "إبدأ", buttonEn: "Search People",
            iconName: "magnifyingglass", columns: ["Person Name", "Group/State/City", "Followers/Members", "ID"],
            defaultUrl: "https://vk.com/search"
        ),
        MarketingToolCard(
            id: "vk_communities", platform: .vk, subMenu: "Communities",
            titleAr: "البحث عن المجموعات والمجتمعات على VK", titleEn: "VK Communities Search",
            descAr: "استخراج المجتمعات والمجموعات المستهدفة على منصة VK",
            descEn: "Search and extract VK groups and communities by keyword",
            buttonAr: "إبدأ", buttonEn: "Search Communities",
            iconName: "person.3.fill", columns: ["Name", "ID", "Members"],
            defaultUrl: "https://vk.com/groups"
        ),
        MarketingToolCard(
            id: "vk_extract", platform: .vk, subMenu: "Extract",
            titleAr: "استخراج البيانات العامة والأصدقاء وأعضاء المجموعات", titleEn: "Extract VK Profile Data, Friends & Group Members",
            descAr: "استخراج جميع البيانات الديموغرافية العامة للعملاء أو الأصدقاء أو أعضاء المجموعات",
            descEn: "Extract public demographic details, friends lists, or group members on VK",
            buttonAr: "البيانات العامة / الأعضاء", buttonEn: "Extract VK Data",
            iconName: "arrow.down.doc.fill", columns: ["Person name", "Country", "Studying in/Work for", "ID"],
            defaultUrl: "https://vk.com"
        ),
        MarketingToolCard(
            id: "vk_request", platform: .vk, subMenu: "Request",
            titleAr: "إرسال طلبات صداقة على VK", titleEn: "Send VK Friend Requests",
            descAr: "إرسال طلبات صداقة للعملاء المستهدفين على VK",
            descEn: "Send automated friend requests to VK user IDs",
            buttonAr: "إبدأ", buttonEn: "Send Friend Requests",
            iconName: "person.badge.plus", columns: ["Name", "ID", "Request State"],
            defaultUrl: "https://vk.com"
        ),
        MarketingToolCard(
            id: "vk_broadcast", platform: .vk, subMenu: "Broadcast",
            titleAr: "إرسال رسائل ترويجية على VK", titleEn: "VK Direct Message Broadcast",
            descAr: "إرسال رسائل ترويجية للعملاء المهتمين على منصة VK",
            descEn: "Send promotional messages to extracted VK user IDs",
            buttonAr: "إبدأ", buttonEn: "Send VK Messages",
            iconName: "paperplane.fill", columns: ["Name", "ID", "Sent or Not"],
            defaultUrl: "https://vk.com/im"
        ),
        MarketingToolCard(
            id: "vk_mention", platform: .vk, subMenu: "Mention",
            titleAr: "إشارة للعملاء في تعليقات VK", titleEn: "VK Post Comment Mention",
            descAr: "عمل منشن للعملاء المهتمين في تعليقات منشورات VK",
            descEn: "Tag target VK users in post comment threads",
            buttonAr: "بدء", buttonEn: "Start Mention",
            iconName: "at", columns: ["@Username", "Time", "State"],
            defaultUrl: "https://vk.com"
        ),

        // ================= REDDIT (V09 04:12 - 04:44) =================
        MarketingToolCard(
            id: "rd_login", platform: .reddit, subMenu: "Login",
            titleAr: "تسجيل الدخول على ريديت", titleEn: "Reddit Login",
            descAr: "أدخل بيانات حسابك على ريديت للمتابعة",
            descEn: "Sign in to your Reddit account",
            buttonAr: "تسجيل الدخول", buttonEn: "Sign In",
            iconName: "bubble.left.and.exclamationmark.bubble.right.fill", columns: ["Username", "State"],
            panelKind: .loginForm, defaultUrl: "https://www.reddit.com/login/"
        ),
        MarketingToolCard(
            id: "rd_search", platform: .reddit, subMenu: "Search",
            titleAr: "البحث واستخراج المجتمعات بكلمات مفتاحية", titleEn: "Search Subreddits by Keyword",
            descAr: "استخراج المجتمعات من خلال البحث بكلمات مفتاحية معينة",
            descEn: "Search and extract Subreddits matching your target keyword",
            buttonAr: "استخراج المجتمعات", buttonEn: "Extract Subreddits",
            iconName: "magnifyingglass", columns: ["Sub Reddit", "Name", "State"],
            defaultUrl: "https://www.reddit.com/subreddits"
        ),
        MarketingToolCard(
            id: "rd_vote_arrows", platform: .reddit, subMenu: "Vote Arrows",
            titleAr: "تصويت إيجابي وحفظ المنشورات (Upvote & Save)", titleEn: "Multi-Account Reddit Upvote & Save Farm",
            descAr: "عمل تصويت إيجابي (Upvote) أو حفظ (Save) أو كلاهما معاً من حسابات متعددة",
            descEn: "Execute multi-account Upvotes and Saves on target Reddit posts",
            buttonAr: "بدء", buttonEn: "Start Upvote / Save",
            iconName: "arrow.up.circle.fill", columns: ["Email", "Password", "Links", "State"],
            defaultUrl: "https://www.reddit.com"
        ),
        MarketingToolCard(
            id: "rd_top_growing", platform: .reddit, subMenu: "Top Growing",
            titleAr: "استخراج المجتمعات الرائدة اليومية والانضمام إليها", titleEn: "Extract Top Growing Communities & Auto-Join",
            descAr: "استخراج المجتمعات الرائدة اليومية وإرسال الانضمام إليها تلقائياً",
            descEn: "Scrape Reddit's daily top-growing communities and join them automatically",
            buttonAr: "استخراج وانضمام", buttonEn: "Extract & Join",
            iconName: "chart.line.uptrend.xyaxis.circle.fill", columns: ["Sub Reddit", "Name", "State"],
            defaultUrl: "https://www.reddit.com/best/communities/1/"
        ),
        MarketingToolCard(
            id: "rd_publishing", platform: .reddit, subMenu: "Publishing",
            titleAr: "النشر التلقائي في مجتمعات ريديت", titleEn: "Subreddit Multimedia Publisher",
            descAr: "النشر على المجتمعات بعنوان ووصف وصورة بعد الانضمام إليها",
            descEn: "Publish posts with Title, Description, and Image across joined Subreddits",
            buttonAr: "بدء النشر", buttonEn: "Publish to Subreddits",
            iconName: "square.and.pencil", columns: ["Groups", "Name", "Time", "State"],
            defaultUrl: "https://www.reddit.com/submit"
        ),

        // ================= AUTO POINT (V09 04:48 - V10 00:44) =================
        MarketingToolCard(
            id: "ap_like4like", platform: .autoPoint, subMenu: "Like4Like",
            titleAr: "تجميع نقاط Like4Like (تويتر وانستجرام)", titleEn: "Like4Like Auto-Point Collector",
            descAr: "تجميع النقاط تلقائياً على موقع Like4Like من خلال حسابات تويتر أو انستجرام",
            descEn: "Automatically earn Like4Like points via Twitter Likes/Follows or Instagram Follows",
            buttonAr: "Start Like / Follow", buttonEn: "Start Like4Like Bot",
            iconName: "hand.thumbsup.circle.fill", columns: ["Platform", "Action", "Points Earned", "State"],
            panelKind: .autoPointExchange, defaultUrl: "https://www.like4like.org"
        ),
        MarketingToolCard(
            id: "ap_getlike", platform: .autoPoint, subMenu: "Getlike",
            titleAr: "تجميع نقاط Getlike (تويتر وانستجرام)", titleEn: "Getlike Auto-Task Executor",
            descAr: "تنفيذ المهام وتجميع النقاط تلقائياً على منصة Getlike",
            descEn: "Automate Getlike tasks on Instagram and Twitter",
            buttonAr: "Start Getlike", buttonEn: "Start Getlike Bot",
            iconName: "star.circle.fill", columns: ["Platform", "Task", "Earned", "State"],
            panelKind: .autoPointExchange, defaultUrl: "https://getlike.io"
        ),
        MarketingToolCard(
            id: "ap_other_platforms", platform: .autoPoint, subMenu: "Other",
            titleAr: "تجميع نقاط منصات التبادل (YouLikeHits / KingdomLikes / FollowFast / LikesPlanet)", titleEn: "Multi-Site Traffic & Point Exchange Bot",
            descAr: "تجميع نقاط لمشاهدات واشتراكات يوتيوب وساوند كلاود وتويتر وانستجرام",
            descEn: "Automate point collection across Like4Like, KingdomLikes, YouLikeHits, FollowFast & LikesPlanet",
            buttonAr: "Start", buttonEn: "Start Exchange Bot",
            iconName: "play.tv.fill", columns: ["Site", "Process Type", "Completed", "State"],
            panelKind: .autoPointExchange, defaultUrl: "https://www.youlikehits.com"
        ),

        // ================= TIKTOK =================
        MarketingToolCard(
            id: "tt_extract", platform: .tiktok, subMenu: "Extract",
            titleAr: "استخراج المتابعين والعملاء من البحث والتعليقات (TikTok)", titleEn: "Extract TikTok Followers, Search & Commenters",
            descAr: "استخراج المتابعين والمتابعون والعملاء من البحث والتعليقات على التيك توك",
            descEn: "Extract TikTok followers, search results, and video commenters",
            buttonAr: "بدء الاستخراج", buttonEn: "Extract TikTok Users",
            iconName: "music.note.list", columns: ["@Username", "Nickname", "Followers", "Likes", "State"],
            browserModalType: .sessionList, defaultUrl: "https://www.tiktok.com"
        ),
        MarketingToolCard(
            id: "tt_marketing", platform: .tiktok, subMenu: "Marketing",
            titleAr: "متابعة وإعجاب وتعليق ومنشن على التيك توك", titleEn: "TikTok Follow, Like, Comment & Mention",
            descAr: "عمل متابعة وإعجاب وتعليق ومنشن للعملاء المستهدفين على التيك توك",
            descEn: "Automate TikTok Follow, Like, Comment, and Mention campaigns",
            buttonAr: "بدء الحملة", buttonEn: "Start TikTok Campaign",
            iconName: "heart.circle.fill", columns: ["Target URL / @User", "Action", "Time", "State"],
            browserModalType: .sessionList, defaultUrl: "https://www.tiktok.com"
        ),
        MarketingToolCard(
            id: "tt_upload", platform: .tiktok, subMenu: "Upload Videos",
            titleAr: "رفع ونشر الفيديوهات تلقائياً على التيك توك", titleEn: "Automated TikTok Video Uploader",
            descAr: "رفع ونشر الفيديوهات بالوصف والهاشتاجات على حسابات التيك توك",
            descEn: "Batch upload videos with captions and hashtags to TikTok accounts",
            buttonAr: "بدء الرفع", buttonEn: "Upload Videos",
            iconName: "arrow.up.doc.on.clipboard", columns: ["Video Path", "Caption", "Account", "State"],
            browserModalType: .sessionList, defaultUrl: "https://www.tiktok.com/upload"
        ),

        // ================= OTHER TOOLS (7 utilities from V10 00:48 - 03:36) =================
        MarketingToolCard(
            id: "ot_download", platform: .otherTools, subMenu: "Download",
            titleAr: "تحميل الفيديوهات المتعددة في نفس الوقت", titleEn: "Concurrent Multi-Video Downloader",
            descAr: "إضافة روابط الفيديوهات وتحديد مسار الحفظ وعدد الفيديوهات التي تريد تحميلها في نفس الوقت",
            descEn: "Download multiple social videos simultaneously with configurable concurrency",
            buttonAr: "بدء التحميل", buttonEn: "Start Download",
            iconName: "arrow.down.circle.fill", columns: ["Link", "Status"],
            panelKind: .videoBatchDownloader
        ),
        MarketingToolCard(
            id: "ot_haraj_rate", platform: .otherTools, subMenu: "Haraj Rate",
            titleAr: "عمل تقييمات على الأنشطة التجارية في موقع حراج", titleEn: "Haraj KSA Seller Review Generator",
            descAr: "عمل تقييمات إيجابية للأنشطة التجارية في موقع حراج من خلال حسابات حراج",
            descEn: "Post automated ratings and reviews on Haraj Saudi Arabia seller profiles",
            buttonAr: "بدء", buttonEn: "Start Haraj Reviews",
            iconName: "star.bubble.fill", columns: ["Links", "State", "Time"],
            browserModalType: .sessionList, defaultUrl: "https://haraj.com.sa"
        ),
        MarketingToolCard(
            id: "ot_magic_editor", platform: .otherTools, subMenu: "Magic Editor",
            titleAr: "دمج الملفات وحذف المكرر والبيانات المتشابهة بشكل كامل", titleEn: "Magic File Merger & Cross-File Deduplicator",
            descAr: "حذف المكرر والبيانات المتشابهة من الملفات بشكل كامل + دمج الملفات وفلترتها وإضافة العملاء",
            descEn: "Deduplicate records across folders by column index and merge/distribute client files",
            buttonAr: "بدء المعالجة", buttonEn: "Run Magic Editor",
            iconName: "wand.and.stars", columns: ["Source File", "Original Rows", "Cleaned Rows", "Status"],
            panelKind: .magicFileEditor
        ),
        MarketingToolCard(
            id: "ot_text_editor", platform: .otherTools, subMenu: "Text Editor",
            titleAr: "تقسيم الملفات بالتساوي وتعديل السطور", titleEn: "Equal File Splitter & Line Trimmer",
            descAr: "تقسيم الملف إلى ملفات بالتساوي + حذف حروف من بداية السطر أو نهاية السطر",
            descEn: "Split large text files into N equal files and trim characters from line start/end",
            buttonAr: "تقسيم وتعديل", buttonEn: "Split & Trim",
            iconName: "doc.on.doc.fill", columns: ["Line", "Modified Output"],
            panelKind: .textFileSplitter
        ),
        MarketingToolCard(
            id: "ot_text_as_vcf", platform: .otherTools, subMenu: "Text As vcf",
            titleAr: "تحويل الأرقام إلى جهات اتصال (Text As VCF)", titleEn: "Convert Phone Numbers to VCF (vCard)",
            descAr: "تحويل ملفات الأرقام النصية إلى ملفات VCF متوافقة مع جهات اتصال جوجل والهاتف",
            descEn: "Convert raw phone number lists into vCard (.vcf) files for Google Contacts sync",
            buttonAr: "حفظ كملف VCF", buttonEn: "Export VCF",
            iconName: "person.crop.rectangle.fill", columns: ["Number", "Contact Name"],
            panelKind: .vcfConverter, defaultUrl: "https://contacts.google.com"
        ),
        MarketingToolCard(
            id: "ot_generate_numbers", platform: .otherTools, subMenu: "Generate",
            titleAr: "توليد أرقام الهواتف التسلسلية والعشوائية", titleEn: "Phone Number Sequence Generator",
            descAr: "توليد قوائم أرقام هواتف تبدأ بمفتاح دولة أو بادئة محددة بالكمية المطلوبة",
            descEn: "Generate sequential or random phone numbers by country prefix, length, and quantity",
            buttonAr: "بدء التوليد", buttonEn: "Generate Numbers",
            iconName: "phone.badge.plus", columns: ["Generated Phone Number"],
            panelKind: .phoneGenerator
        ),
        MarketingToolCard(
            id: "ot_hashtags", platform: .otherTools, subMenu: "Hashtags",
            titleAr: "البحث وتحليل الهاشتاجات (لكل المنصات)", titleEn: "Multi-Platform Hashtag Generator & Analyzer",
            descAr: "استخراج وتحليل الهاشتاجات المرتبطة بكلمة مفتاحية (Instagram / X / TikTok / YouTube / Facebook)",
            descEn: "Generate and analyze high-reach hashtags across Instagram, X, TikTok, YouTube & Facebook",
            buttonAr: "بدء البحث", buttonEn: "Search Hashtags",
            iconName: "number", columns: ["Hashtags", "Analysis"],
            panelKind: .hashtagAnalyzer
        )
    ]

    // MARK: - Complete 29 B2B Connectors (Exact order & columns from Video V11)
    public static let allB2BConnectors: [B2BConnectorSpec] = [
        B2BConnectorSpec(
            id: "aqar_city", sidebarName: "Aqar city", titleAr: "استخراج من موقع عقار ستي (3qar City)",
            portalUrl: "https://3qar.me", openButtonLabel: "Open 3qar City",
            columns: ["Link", "Name", "Price", "Owner Name", "Phone", "Whatsapp", "Time", "Details", "Category", "Property area"]
        ),
        B2BConnectorSpec(
            id: "maroof_sa", sidebarName: "Maroof SA", titleAr: "استخراج من موقع معروف السعودي (Maroof)",
            portalUrl: "https://maroof.sa", openButtonLabel: "Open Maroof",
            columns: ["ID", "Name", "Business's Email", "Customer Phone", "Rating", "TotalReview", "City", "Region", "Description"]
        ),
        B2BConnectorSpec(
            id: "onshobbak", sidebarName: "OnShobbak", titleAr: "استخراج من موقع شباك (OnShobbak)",
            portalUrl: "https://onshobbak.com", openButtonLabel: "Open OnShobbak",
            columns: ["Link", "Name", "Owner", "Owner's Country", "Phone", "Details"]
        ),
        B2BConnectorSpec(
            id: "haraj", sidebarName: "Haraj", titleAr: "استخراج من موقع حراج السعودي (Haraj)",
            portalUrl: "https://haraj.com.sa", openButtonLabel: "Open Haraj",
            columns: ["Link", "Name", "Phone", "Address", "Time", "Owner", "Rate", "Details", "Followers"]
        ),
        B2BConnectorSpec(
            id: "open_soq", sidebarName: "Open Soq", titleAr: "استخراج من السوق المفتوح (OpenSooq - 20 دولة)",
            portalUrl: "https://opensooq.com", openButtonLabel: "Open OpenSooq",
            columns: ["Link", "Name", "Owner", "Phone", "Price", "Details", "Other"],
            countries: ["Saudi Arabia", "UAE", "Egypt", "Kuwait", "Jordan", "Oman", "Qatar", "Bahrain", "Iraq", "Morocco", "Algeria", "Tunisia", "Libya", "Lebanon", "Palestine", "Sudan", "Yemen", "Syria", "Mauritania", "Turkey"]
        ),
        B2BConnectorSpec(
            id: "dubizzle", sidebarName: "Dubizzle", titleAr: "استخراج من أوليكس / دوبيزل للدول العربية (OLX / Dubizzle)",
            portalUrl: "https://www.dubizzle.com.eg", openButtonLabel: "Open Dubizzle",
            columns: ["Link", "Name", "Owner", "Phone", "Address", "Price", "ID", "Details", "Other Info", "Category"],
            countries: ["Egypt", "Saudi Arabia", "Oman", "Lebanon", "Qatar", "Kuwait", "Bahrain"]
        ),
        B2BConnectorSpec(
            id: "dubizzle_uae", sidebarName: "Dubizzle UAE", titleAr: "استخراج من دوبيزل الإمارات (Dubizzle UAE)",
            portalUrl: "https://uae.dubizzle.com", openButtonLabel: "Open Dubizzle UAE",
            columns: ["Link", "Name", "Owner", "Phone", "Address", "Price", "ID", "Details", "Other Info", "Category"]
        ),
        B2BConnectorSpec(
            id: "bayut", sidebarName: "Bayut", titleAr: "استخراج من موقع بيوت العقاري (Bayut)",
            portalUrl: "https://www.bayut.com", openButtonLabel: "Open Bayut",
            columns: ["Links", "Name", "Address", "Price", "Phone", "Owner Name"],
            isSingleStage: true
        ),
        B2BConnectorSpec(
            id: "semsar", sidebarName: "Semsar", titleAr: "استخراج من موقع سمسار (Semsar)",
            portalUrl: "https://www.semsarmasr.com", openButtonLabel: "Open Semsar",
            columns: ["Link", "Name", "Phone", "Price", "Address", "Details"],
            isSingleStage: true
        ),
        B2BConnectorSpec(
            id: "blue_pages", sidebarName: "Blue Pages", titleAr: "استخراج من الدليل الأزرق (Blue Pages)",
            portalUrl: "https://bluepages.com.eg", openButtonLabel: "Open BluePages",
            columns: ["Link", "Company Name", "Phone", "Address", "Category", "Website"],
            isSingleStage: true
        ),
        B2BConnectorSpec(
            id: "mourjan", sidebarName: "Mourjan", titleAr: "استخراج من موقع مرجان (Mourjan)",
            portalUrl: "https://www.mourjan.com", openButtonLabel: "Open mourjan",
            columns: ["ID", "Name", "Phone", "E-mail", "Time", "Details"]
        ),
        B2BConnectorSpec(
            id: "google_map", sidebarName: "Google Map", titleAr: "استخراج بيانات الشركات والأنشطة من خرائط جوجل (Google Maps)",
            portalUrl: "https://www.google.com/maps", openButtonLabel: "Open Google Maps",
            columns: ["Links", "Name", "Phone", "Address", "FullAddress", "Category", "Rate", "Number", "Website", "Email", "WhatsApp"],
            supportsEmailWhatsAppToggle: true
        ),
        B2BConnectorSpec(
            id: "google_travel", sidebarName: "Google Travel", titleAr: "استخراج الفنادق والسياحة من جوجل ترافيل (Google Travel)",
            portalUrl: "https://www.google.com/travel/hotels", openButtonLabel: "Search Google Travel",
            columns: ["Link", "Name", "Phone", "Address", "Rate", "Website"]
        ),
        B2BConnectorSpec(
            id: "property_finder", sidebarName: "Property", titleAr: "استخراج من بروبرتي فايندر (Property Finder)",
            portalUrl: "https://www.propertyfinder.ae", openButtonLabel: "Open Property Finder",
            columns: ["Link", "Name", "Phone", "Whatsapp", "Address", "Properties"],
            countries: ["UAE", "Egypt", "Saudi Arabia", "Qatar", "Bahrain"]
        ),
        B2BConnectorSpec(
            id: "aqarmab", sidebarName: "Aqarmab", titleAr: "استخراج من موقع عقار ماب (AqarMap)",
            portalUrl: "https://aqarmap.com.eg", openButtonLabel: "Open AqarMap",
            columns: ["Link", "Title", "Owner", "Phone", "Address", "Price", "Time", "Details", "Other"],
            countries: ["Egypt", "Saudi Arabia"]
        ),
        B2BConnectorSpec(
            id: "ejaar", sidebarName: "Ejaar", titleAr: "استخراج من موقع إيجار (Ejaar)",
            portalUrl: "https://www.ejar.sa", openButtonLabel: "Open Egaar",
            columns: ["Name", "Phone", "E-mail", "price", "link"]
        ),
        B2BConnectorSpec(
            id: "waseet", sidebarName: "Waseet", titleAr: "استخراج من موقع الوسيط (Al Waseet)",
            portalUrl: "https://www.ewaseet.com", openButtonLabel: "Open Waseet",
            columns: ["Links", "Name", "Phone", "Address", "Details"]
        ),
        B2BConnectorSpec(
            id: "yellow_pages", sidebarName: "Yellow Pages", titleAr: "استخراج من الصفحات الصفراء (كندا / الإمارات / مصر)",
            portalUrl: "https://www.yellowpages.ca", openButtonLabel: "Open Yellow Pages Ca / UAE",
            columns: ["Link", "Name", "Phone", "Address", "Website"],
            countries: ["Canada (yellowpages.ca)", "UAE (yellowpages-uae.com)", "Egypt (yellowpages.com.eg)"]
        ),
        B2BConnectorSpec(
            id: "four_sale", sidebarName: "4 Sale", titleAr: "استخراج من موقع فور سيل الكويت (4Sale)",
            portalUrl: "https://www.q84sale.com", openButtonLabel: "Open 4Sale",
            columns: ["Links", "Name", "Phone", "Email", "Address", "Content"]
        ),
        B2BConnectorSpec(
            id: "mzad_qatar", sidebarName: "Mzad", titleAr: "استخراج من موقع مزاد قطر (Mzad Qatar)",
            portalUrl: "https://mzadqatar.com", openButtonLabel: "Open Mzadqatar",
            columns: ["Links", "Name", "Phone", "Email", "Address", "Content"]
        ),
        B2BConnectorSpec(
            id: "koshofat", sidebarName: "Koshofat", titleAr: "استخراج بيانات الأطباء والعيادات من موقع كشوفات",
            portalUrl: "https://koshofat.com", openButtonLabel: "Koshofat",
            columns: ["Links", "Name", "Phone", "Address", "Specialization"]
        ),
        B2BConnectorSpec(
            id: "altibbi", sidebarName: "Altibbi", titleAr: "استخراج بيانات الأطباء من موقع الطبي (Altibbi)",
            portalUrl: "https://altibbi.com", openButtonLabel: "Open Altibbi",
            columns: ["Link", "Name", "Phone", "Address", "Specialization"]
        ),
        B2BConnectorSpec(
            id: "four_omra", sidebarName: "4Omra", titleAr: "استخراج شركات الحج والعمرة (4Omra)",
            portalUrl: "https://www.umrah.com.sa", openButtonLabel: "Open Omra Website",
            columns: ["Link", "Name", "Country", "Category", "City", "Area", "Address", "Phone1", "Phone2", "Fax"]
        ),
        B2BConnectorSpec(
            id: "sa_aqar", sidebarName: "Sa-aqar", titleAr: "استخراج من موقع عقار وسندك السعودي (Sa-Aqar / Sanadak)",
            portalUrl: "https://sa.aqar.fm", openButtonLabel: "Open Sa-Aqar / Sanadak",
            columns: ["Link", "Ad License", "Offer Name", "Publisher Name", "Location", "FAL License", "Phone"]
        ),
        B2BConnectorSpec(
            id: "oued_kniss", sidebarName: "Oued Kniss", titleAr: "استخراج من موقع واد كنيس الجزائري (Ouedkniss)",
            portalUrl: "https://www.ouedkniss.com", openButtonLabel: "Open Ouedkniss",
            columns: ["Link", "Name", "Description", "City", "Region", "Phone", "Another"]
        ),
        B2BConnectorSpec(
            id: "earabii_market", sidebarName: "Earabii Market", titleAr: "استخراج من السوق العربي (Earabii Market)",
            portalUrl: "https://earabiimarket.com", openButtonLabel: "Open Earabiimarket",
            columns: ["Link", "Name", "Description", "City", "Address", "Phone", "Website", "Email"],
            supportsEmailWhatsAppToggle: true
        ),
        B2BConnectorSpec(
            id: "professional_search", sidebarName: "Professional", titleAr: "استخراج البيانات من محركات البحث (Google / Bing / Yahoo)",
            portalUrl: "https://www.google.com", openButtonLabel: "Extract from Search Engine",
            columns: ["Extracted Data (Email / Phone / Profile)", "Country", "Website", "Search Engine"]
        ),
        B2BConnectorSpec(
            id: "extract_email", sidebarName: "Extract Email", titleAr: "استخراج الإيميلات والهواتف والواتساب من أي موقع ويب",
            portalUrl: "https://www.google.com", openButtonLabel: "Extract Email & Phone",
            columns: ["Link", "Email", "Phone", "WhatsApp"]
        ),
        B2BConnectorSpec(
            id: "bo_shamlan", sidebarName: "BoShamlan", titleAr: "استخراج من دليل عقارات بوشملان الكويتي (Bu Shamlan)",
            portalUrl: "https://www.boshamlan.com", openButtonLabel: "Extract BoShamlan",
            columns: ["Name", "Details", "Price", "Phone", "WhatsApp"],
            isSingleStage: true
        )
    ]

    // MARK: - Official 26 SMTP/POP3 Presets (From https://senderprov.com/en/blog/list-of-smtp-and-pop3-servers-en)
    public static let smtpServerPresets: [SMTPServerPreset] = [
        SMTPServerPreset(provider: "Gmail", smtpHost: "smtp.gmail.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.gmail.com", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Outlook.com / Hotmail", smtpHost: "smtp.live.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop3.live.com", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Office365.com", smtpHost: "smtp.office365.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "outlook.office365.com", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Yahoo Mail", smtpHost: "smtp.mail.yahoo.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.mail.yahoo.com", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Yahoo Mail Plus", smtpHost: "plus.smtp.mail.yahoo.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "plus.pop.mail.yahoo.com", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Yahoo UK", smtpHost: "smtp.mail.yahoo.co.uk", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.mail.yahoo.co.uk", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Yahoo Deutschland", smtpHost: "smtp.mail.yahoo.de", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.mail.yahoo.de", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Yahoo AU/NZ", smtpHost: "smtp.mail.yahoo.com.au", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.mail.yahoo.com.au", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Zoho Mail", smtpHost: "smtp.zoho.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.zoho.com", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Mail.com", smtpHost: "smtp.mail.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.mail.com", pop3PortSSL: 995),
        SMTPServerPreset(provider: "GMX.com", smtpHost: "smtp.gmx.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.gmx.com", pop3PortSSL: 995),
        SMTPServerPreset(provider: "iCloud Mail (Apple)", smtpHost: "smtp.mail.me.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "imap.mail.me.com", pop3PortSSL: 993),
        SMTPServerPreset(provider: "AT&T", smtpHost: "outbound.att.net", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "inbound.att.net", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Verizon", smtpHost: "outgoing.verizon.net", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "incoming.verizon.net", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Comcast", smtpHost: "smtp.comcast.net", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "mail.comcast.net", pop3PortSSL: 995),
        SMTPServerPreset(provider: "Orange", smtpHost: "smtp.orange.net", smtpPortSSL: 465, smtpPortTLS: 25, pop3Host: "pop.orange.net", pop3PortSSL: 110),
        SMTPServerPreset(provider: "T-Online", smtpHost: "securesmtp.t-online.de", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "securepop.t-online.de", pop3PortSSL: 995),
        SMTPServerPreset(provider: "1&1 (IONOS)", smtpHost: "smtp.1and1.com", smtpPortSSL: 465, smtpPortTLS: 587, pop3Host: "pop.1and1.com", pop3PortSSL: 995)
    ]

    public static func tools(for platform: MarketingPlatform, subMenu: String) -> [MarketingToolCard] {
        allMarketingTools.filter { $0.platform == platform && $0.subMenu == subMenu }
    }
}
