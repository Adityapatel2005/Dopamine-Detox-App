import SwiftUI

struct OnboardingAnswerOption: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
}

struct OnboardingAppTargetGroup: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let options: [OnboardingAnswerOption]
}

struct OnboardingQuestion: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let options: [OnboardingAnswerOption]
    let allowsMultipleSelection: Bool

    init(
        id: String,
        title: String,
        subtitle: String,
        options: [OnboardingAnswerOption],
        allowsMultipleSelection: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.options = options
        self.allowsMultipleSelection = allowsMultipleSelection
    }
}

private struct PersonalizedPlanRow: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
}

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var step = 0
    @State private var onboardingAnswers: [String: OnboardingAnswerOption] = [:]
    @State private var selectedAppTargetIDs: Set<String> = []
    @State private var expandedAppTargetGroupIDs: Set<String> = ["short-video", "social-feeds"]
    @ScaledMetric(relativeTo: .largeTitle) private var headlineFontSize: CGFloat = 32
    @ScaledMetric(relativeTo: .body) private var contentSpacing: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var horizontalPadding: CGFloat = 20

    private let questions: [OnboardingQuestion] = [
        OnboardingQuestion(
            id: "outcome",
            title: "What are you trying to get back?",
            subtitle: "Name the thing that will feel better when scrolling stops.",
            options: [
                OnboardingAnswerOption(id: "sleep", title: "Sleep", subtitle: "Stop the late-night loop.", systemImage: "moon.zzz"),
                OnboardingAnswerOption(id: "grades", title: "Grades & studying", subtitle: "Stay with the work longer.", systemImage: "graduationcap"),
                OnboardingAnswerOption(id: "deep-work", title: "Deep work", subtitle: "Protect serious focus blocks.", systemImage: "laptopcomputer"),
                OnboardingAnswerOption(id: "real-life", title: "Real life", subtitle: "More time with people and plans.", systemImage: "person.2"),
                OnboardingAnswerOption(id: "self-control", title: "Self-control", subtitle: "Break the reflex open.", systemImage: "hand.raised"),
                OnboardingAnswerOption(id: "health", title: "Gym or health", subtitle: "Keep energy for your body.", systemImage: "heart")
            ]
        ),
        OnboardingQuestion(
            id: "trigger",
            title: "What usually starts the spiral?",
            subtitle: "This helps Lockd frame the first intervention around your real trigger.",
            options: [
                OnboardingAnswerOption(id: "boredom", title: "Boredom", subtitle: "Nothing to do turns into a scroll.", systemImage: "clock"),
                OnboardingAnswerOption(id: "stress", title: "Stress", subtitle: "You escape when pressure spikes.", systemImage: "exclamationmark.triangle"),
                OnboardingAnswerOption(id: "notifications", title: "Notifications", subtitle: "One ping pulls you out.", systemImage: "bell.badge"),
                OnboardingAnswerOption(id: "one-video", title: "Just one video", subtitle: "The first hit becomes a session.", systemImage: "play.rectangle"),
                OnboardingAnswerOption(id: "avoidance", title: "Avoiding work", subtitle: "Scrolling becomes delay mode.", systemImage: "doc.text.magnifyingglass"),
                OnboardingAnswerOption(id: "autopilot", title: "Late-night autopilot", subtitle: "You open apps before thinking.", systemImage: "bed.double")
            ]
        ),
        OnboardingQuestion(
            id: "weakSpot",
            title: "When are you easiest to break?",
            subtitle: "Choose the window where Lockd should watch for weak spots first.",
            options: [
                OnboardingAnswerOption(id: "morning-bed", title: "Morning in bed", subtitle: "Before the day gets moving.", systemImage: "sunrise"),
                OnboardingAnswerOption(id: "class-work", title: "During class or work", subtitle: "When attention starts leaking.", systemImage: "briefcase"),
                OnboardingAnswerOption(id: "after-dinner", title: "After dinner", subtitle: "The couch-scroll danger zone.", systemImage: "fork.knife"),
                OnboardingAnswerOption(id: "before-sleep", title: "Before sleep", subtitle: "The last scroll stretches out.", systemImage: "moon"),
                OnboardingAnswerOption(id: "weekends", title: "Weekends", subtitle: "Unstructured time gets loud.", systemImage: "calendar"),
                OnboardingAnswerOption(id: "alone", title: "Whenever I'm alone", subtitle: "Quiet moments turn into feeds.", systemImage: "person")
            ]
        ),
        OnboardingQuestion(
            id: "apps",
            title: "What do you lose the most time to?",
            subtitle: "Choose every category that fits. On iPhone you can choose any apps, categories, and websites with Screen Time.",
            options: [],
            allowsMultipleSelection: true
        ),
        OnboardingQuestion(
            id: "strictness",
            title: "How aggressive should Lockd be?",
            subtitle: "Pick the level of friction you will actually respect.",
            options: [
                OnboardingAnswerOption(id: "gentle", title: "Gentle pause", subtitle: "A short reset before opening.", systemImage: "hand.raised"),
                OnboardingAnswerOption(id: "normal", title: "Normal lock", subtitle: "Protect selected targets during a lock-in.", systemImage: "lock"),
                OnboardingAnswerOption(id: "hard", title: "Hard block", subtitle: "No easy exits during protected time.", systemImage: "lock.shield"),
                OnboardingAnswerOption(id: "monk", title: "Monk Mode", subtitle: "Go strict for serious resets.", systemImage: "flame")
            ]
        ),
        OnboardingQuestion(
            id: "firstBlock",
            title: "What should your first protected block be?",
            subtitle: "Lockd will turn this into your first recommended schedule.",
            options: [
                OnboardingAnswerOption(id: "focus-25", title: "25 min focus", subtitle: "Quick lock-in, low friction.", systemImage: "timer"),
                OnboardingAnswerOption(id: "study-45", title: "45 min study", subtitle: "A classwork-sized session.", systemImage: "book.closed"),
                OnboardingAnswerOption(id: "deep-90", title: "90 min deep work", subtitle: "Long enough to get serious.", systemImage: "brain.head.profile"),
                OnboardingAnswerOption(id: "bedtime", title: "Bedtime lock", subtitle: "Protect sleep before it slips.", systemImage: "moon.zzz"),
                OnboardingAnswerOption(id: "morning", title: "Morning lock", subtitle: "Start without feeds.", systemImage: "sunrise"),
                OnboardingAnswerOption(id: "weekend", title: "Weekend reset", subtitle: "Block the drift when time is loose.", systemImage: "calendar.badge.clock")
            ]
        )
    ]

    private let appTargetGroups: [OnboardingAppTargetGroup] = [
        OnboardingAppTargetGroup(
            id: "short-video",
            title: "Short video",
            subtitle: "Fast reward loops and algorithmic feeds.",
            options: [
                OnboardingAnswerOption(id: "tiktok", title: "TikTok", subtitle: "For You Page.", systemImage: "music.note"),
                OnboardingAnswerOption(id: "youtube-shorts", title: "YouTube Shorts", subtitle: "Shorts feed.", systemImage: "play.rectangle"),
                OnboardingAnswerOption(id: "instagram-reels", title: "Instagram Reels", subtitle: "Reels and Explore.", systemImage: "camera"),
                OnboardingAnswerOption(id: "snapchat-spotlight", title: "Snapchat Spotlight", subtitle: "Spotlight videos.", systemImage: "bolt"),
                OnboardingAnswerOption(id: "facebook-reels", title: "Facebook Reels", subtitle: "Reels feed.", systemImage: "f.circle"),
                OnboardingAnswerOption(id: "twitch", title: "Twitch", subtitle: "Streams and clips.", systemImage: "play.tv"),
                OnboardingAnswerOption(id: "kick", title: "Kick", subtitle: "Live streams.", systemImage: "bolt.fill")
            ]
        ),
        OnboardingAppTargetGroup(
            id: "social-feeds",
            title: "Social feeds",
            subtitle: "Feeds, comments, trends, and rabbit holes.",
            options: [
                OnboardingAnswerOption(id: "instagram", title: "Instagram", subtitle: "Stories, feed, explore.", systemImage: "camera"),
                OnboardingAnswerOption(id: "reddit", title: "Reddit", subtitle: "Threads and communities.", systemImage: "bubble.left"),
                OnboardingAnswerOption(id: "x", title: "X", subtitle: "Timeline and trends.", systemImage: "xmark"),
                OnboardingAnswerOption(id: "threads", title: "Threads", subtitle: "Text social feed.", systemImage: "at"),
                OnboardingAnswerOption(id: "facebook", title: "Facebook", subtitle: "Feed and groups.", systemImage: "person.3"),
                OnboardingAnswerOption(id: "pinterest", title: "Pinterest", subtitle: "Idea rabbit holes.", systemImage: "pin"),
                OnboardingAnswerOption(id: "tumblr", title: "Tumblr", subtitle: "Blogs and fandoms.", systemImage: "text.bubble"),
                OnboardingAnswerOption(id: "bluesky", title: "Bluesky", subtitle: "Social timeline.", systemImage: "cloud"),
                OnboardingAnswerOption(id: "lemon8", title: "Lemon8", subtitle: "Lifestyle feed.", systemImage: "leaf")
            ]
        ),
        OnboardingAppTargetGroup(
            id: "messaging",
            title: "Messaging pull",
            subtitle: "Apps that turn one reply into a loop.",
            options: [
                OnboardingAnswerOption(id: "discord", title: "Discord", subtitle: "Servers and DMs.", systemImage: "bubble.left.and.bubble.right"),
                OnboardingAnswerOption(id: "snapchat", title: "Snapchat", subtitle: "Streaks and stories.", systemImage: "camera.viewfinder"),
                OnboardingAnswerOption(id: "whatsapp", title: "WhatsApp", subtitle: "Chats and groups.", systemImage: "phone.bubble"),
                OnboardingAnswerOption(id: "messenger", title: "Messenger", subtitle: "DMs and calls.", systemImage: "message"),
                OnboardingAnswerOption(id: "telegram", title: "Telegram", subtitle: "Channels and chats.", systemImage: "paperplane"),
                OnboardingAnswerOption(id: "imessage", title: "iMessage", subtitle: "Text threads.", systemImage: "message.fill")
            ]
        ),
        OnboardingAppTargetGroup(
            id: "streaming",
            title: "Streaming",
            subtitle: "Long-form video and binge sessions.",
            options: [
                OnboardingAnswerOption(id: "youtube", title: "YouTube", subtitle: "Videos and recommendations.", systemImage: "play.rectangle"),
                OnboardingAnswerOption(id: "netflix", title: "Netflix", subtitle: "Shows and autoplay.", systemImage: "tv"),
                OnboardingAnswerOption(id: "hulu", title: "Hulu", subtitle: "TV episodes.", systemImage: "tv"),
                OnboardingAnswerOption(id: "disney", title: "Disney+", subtitle: "Movies and shows.", systemImage: "sparkles"),
                OnboardingAnswerOption(id: "prime-video", title: "Prime Video", subtitle: "Streaming library.", systemImage: "play.tv"),
                OnboardingAnswerOption(id: "max", title: "Max", subtitle: "Shows and movies.", systemImage: "movieclapper"),
                OnboardingAnswerOption(id: "crunchyroll", title: "Crunchyroll", subtitle: "Anime episodes.", systemImage: "play.square.stack")
            ]
        ),
        OnboardingAppTargetGroup(
            id: "dating",
            title: "Dating",
            subtitle: "Swipe loops and check-backs.",
            options: [
                OnboardingAnswerOption(id: "tinder", title: "Tinder", subtitle: "Swipe sessions.", systemImage: "flame"),
                OnboardingAnswerOption(id: "hinge", title: "Hinge", subtitle: "Profiles and messages.", systemImage: "heart"),
                OnboardingAnswerOption(id: "bumble", title: "Bumble", subtitle: "Matches and chats.", systemImage: "sparkles")
            ]
        ),
        OnboardingAppTargetGroup(
            id: "shopping-food",
            title: "Shopping & food",
            subtitle: "Impulse browsing and delivery loops.",
            options: [
                OnboardingAnswerOption(id: "amazon", title: "Amazon", subtitle: "Browsing and deals.", systemImage: "cart"),
                OnboardingAnswerOption(id: "temu", title: "Temu", subtitle: "Deals feed.", systemImage: "tag"),
                OnboardingAnswerOption(id: "shein", title: "Shein", subtitle: "Shopping feed.", systemImage: "bag"),
                OnboardingAnswerOption(id: "doordash", title: "DoorDash", subtitle: "Food delivery.", systemImage: "takeoutbag.and.cup.and.straw"),
                OnboardingAnswerOption(id: "uber-eats", title: "Uber Eats", subtitle: "Food delivery.", systemImage: "fork.knife")
            ]
        ),
        OnboardingAppTargetGroup(
            id: "browsers-web",
            title: "Browsers & web",
            subtitle: "Search loops and websites you want blocked.",
            options: [
                OnboardingAnswerOption(id: "safari", title: "Safari", subtitle: "Web browsing.", systemImage: "safari"),
                OnboardingAnswerOption(id: "chrome", title: "Chrome", subtitle: "Web browsing.", systemImage: "globe"),
                OnboardingAnswerOption(id: "google", title: "Google", subtitle: "Search loops.", systemImage: "magnifyingglass"),
                OnboardingAnswerOption(id: "reddit-web", title: "Reddit web", subtitle: "Browser rabbit holes.", systemImage: "network"),
                OnboardingAnswerOption(id: "adult-websites", title: "Adult websites", subtitle: "Web domains.", systemImage: "shield")
            ]
        ),
        OnboardingAppTargetGroup(
            id: "games",
            title: "Games",
            subtitle: "Matches, quests, streaks, and daily rewards.",
            options: [
                OnboardingAnswerOption(id: "roblox", title: "Roblox", subtitle: "Games and worlds.", systemImage: "gamecontroller"),
                OnboardingAnswerOption(id: "clash-royale", title: "Clash Royale", subtitle: "Matches and chests.", systemImage: "crown"),
                OnboardingAnswerOption(id: "brawl-stars", title: "Brawl Stars", subtitle: "Quick matches.", systemImage: "star"),
                OnboardingAnswerOption(id: "fortnite", title: "Fortnite", subtitle: "Matches and quests.", systemImage: "scope"),
                OnboardingAnswerOption(id: "cod-mobile", title: "Call of Duty Mobile", subtitle: "Ranked matches.", systemImage: "target"),
                OnboardingAnswerOption(id: "pokemon-go", title: "Pokemon GO", subtitle: "Walks and raids.", systemImage: "mappin.and.ellipse")
            ]
        )
    ]

    var body: some View {
        ZStack {
            LockdTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: contentSpacing) {
                    progressHeader
                    if isPlanStep {
                        planReveal
                    } else {
                        questionView(questions[step])
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 18)
                .padding(.bottom, 16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            footerButton
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(LockdTheme.background)
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lockd")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(LockdTheme.secondaryText)

            ProgressView(value: Double(step + 1), total: Double(totalSteps))
                .tint(LockdTheme.protectedGreen)
                .accessibilityLabel("Onboarding progress")
                .accessibilityValue("Step \(step + 1) of \(totalSteps)")
        }
    }

    private func questionView(_ question: OnboardingQuestion) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(question.title)
                .font(.system(size: headlineFontSize, weight: .black, design: .rounded))
                .foregroundStyle(LockdTheme.primaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.74)
                .accessibilityAddTraits(.isHeader)

            Text(question.subtitle)
                .font(.body)
                .foregroundStyle(LockdTheme.secondaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            if question.allowsMultipleSelection {
                appTargetsView
            } else {
                VStack(spacing: 10) {
                    ForEach(question.options) { option in
                        answerButton(option, questionID: question.id)
                    }
                }
            }
        }
    }

    private func answerButton(_ option: OnboardingAnswerOption, questionID: String) -> some View {
        let isSelected = onboardingAnswers[questionID] == option

        return Button {
            onboardingAnswers[questionID] = option
        } label: {
            answerButtonContent(
                option,
                isSelected: isSelected,
                selectedSystemImage: "checkmark.circle.fill",
                unselectedSystemImage: "circle"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Selects this onboarding answer.")
    }

    private var appTargetsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            appTargetSelectionSummary

            ForEach(appTargetGroups) { group in
                DisclosureGroup(isExpanded: expandedBinding(for: group.id)) {
                    VStack(spacing: 8) {
                        ForEach(group.options) { option in
                            appTargetButton(option)
                        }
                    }
                    .padding(.top, 10)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "folder")
                            .foregroundStyle(LockdTheme.protectedGreen)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(group.title)
                                .font(.headline)
                                .foregroundStyle(LockdTheme.primaryText)
                            Text(group.subtitle)
                                .font(.footnote)
                                .foregroundStyle(LockdTheme.secondaryText)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 8)

                        Text("\(selectedCount(in: group))")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(selectedCount(in: group) > 0 ? .black : LockdTheme.secondaryText)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(selectedCount(in: group) > 0 ? LockdTheme.protectedGreen : LockdTheme.elevatedSurface)
                            .clipShape(Capsule())
                    }
                    .contentShape(Rectangle())
                }
                .padding(12)
                .background(LockdTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: LockdTheme.compactRadius, style: .continuous))
                .tint(LockdTheme.protectedGreen)
                .accessibilityElement(children: .contain)
            }
        }
    }

    private var appTargetSelectionSummary: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checklist")
                .foregroundStyle(LockdTheme.protectedGreen)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(selectedAppTargetCount) selected")
                    .font(.headline)
                    .foregroundStyle(LockdTheme.primaryText)
                Text(selectedAppTargetCount == 0 ? "Pick one or more targets. You will choose exact apps with Screen Time on iPhone." : selectedAppTargetSummary)
                    .font(.footnote)
                    .foregroundStyle(LockdTheme.secondaryText)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.compactRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(selectedAppTargetCount) selected")
    }

    private func appTargetButton(_ option: OnboardingAnswerOption) -> some View {
        let isSelected = selectedAppTargetIDs.contains(option.id)

        return Button {
            if isSelected {
                selectedAppTargetIDs.remove(option.id)
            } else {
                selectedAppTargetIDs.insert(option.id)
            }
        } label: {
            answerButtonContent(
                option,
                isSelected: isSelected,
                selectedSystemImage: "checkmark.square.fill",
                unselectedSystemImage: "square"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Toggles this app or category for your first Lockd setup.")
    }

    private func answerButtonContent(
        _ option: OnboardingAnswerOption,
        isSelected: Bool,
        selectedSystemImage: String,
        unselectedSystemImage: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: option.systemImage)
                .frame(width: 24)
                .foregroundStyle(isSelected ? .black : LockdTheme.protectedGreen)

            VStack(alignment: .leading, spacing: 4) {
                Text(option.title)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                Text(option.subtitle)
                    .font(.footnote)
                    .foregroundStyle(isSelected ? .black.opacity(0.72) : LockdTheme.secondaryText)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Image(systemName: isSelected ? selectedSystemImage : unselectedSystemImage)
                .foregroundStyle(isSelected ? .black : LockdTheme.secondaryText)
        }
        .foregroundStyle(isSelected ? .black : LockdTheme.primaryText)
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .background(isSelected ? LockdTheme.protectedGreen : LockdTheme.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.compactRadius, style: .continuous))
        .contentShape(Rectangle())
    }

    private var planReveal: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Your Lockd setup is ready")
                .font(.system(size: headlineFontSize, weight: .black, design: .rounded))
                .foregroundStyle(LockdTheme.primaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.74)
                .accessibilityAddTraits(.isHeader)

            Text("Not another app limit. Screen Time is the engine. Lockd is the behavior layer.")
                .font(.body)
                .foregroundStyle(LockdTheme.secondaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(lockdDifferentiatorRows) { row in
                    planRow(row)
                }
            }

            VStack(spacing: 10) {
                ForEach(personalizedPlanRows) { row in
                    planRow(row)
                }
            }
        }
    }

    private func planRow(_ row: PersonalizedPlanRow) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(row.title)
                    .font(.headline)
                Text(row.subtitle)
                    .font(.footnote)
                    .foregroundStyle(LockdTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } icon: {
            Image(systemName: row.systemImage)
                .foregroundStyle(LockdTheme.protectedGreen)
        }
        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
        .padding(14)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.compactRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var footerButton: some View {
        LockdButton(
            footerButtonTitle,
            systemImage: isPlanStep ? "lock.open.fill" : "arrow.right",
            accessibilityHint: isPlanStep ? "Opens the required Lockd trial screen." : "Moves to the next onboarding step."
        ) {
            if isPlanStep {
                onComplete()
            } else if canAdvanceCurrentStep {
                step += 1
            }
        }
    }

    private var footerButtonTitle: String {
        if isPlanStep {
            return "Start 7-day trial"
        }

        guard !canAdvanceCurrentStep else {
            return "Next"
        }

        return currentQuestionAllowsMultipleSelection ? "Choose at least one" : "Choose one"
    }

    private var personalizedPlanRows: [PersonalizedPlanRow] {
        [
            PersonalizedPlanRow(
                id: "outcome",
                title: "What you want back",
                subtitle: onboardingAnswers["outcome"]?.title ?? "Protect attention",
                systemImage: "target"
            ),
            PersonalizedPlanRow(
                id: "trigger",
                title: "Spiral trigger",
                subtitle: onboardingAnswers["trigger"]?.title ?? "Your main trigger",
                systemImage: "bell.badge"
            ),
            PersonalizedPlanRow(
                id: "weakSpot",
                title: "Weak spot window",
                subtitle: onboardingAnswers["weakSpot"]?.title ?? "Your highest-risk time",
                systemImage: "clock.badge.exclamationmark"
            ),
            PersonalizedPlanRow(
                id: "apps",
                title: "First targets",
                subtitle: selectedAppTargetSummary,
                systemImage: "apps.iphone"
            ),
            PersonalizedPlanRow(
                id: "strictness",
                title: "Protection level",
                subtitle: onboardingAnswers["strictness"]?.title ?? "Normal lock",
                systemImage: "slider.horizontal.3"
            ),
            PersonalizedPlanRow(
                id: "firstBlock",
                title: "First lock",
                subtitle: onboardingAnswers["firstBlock"]?.title ?? "25 min focus",
                systemImage: "timer"
            )
        ]
    }

    private var lockdDifferentiatorRows: [PersonalizedPlanRow] {
        [
            PersonalizedPlanRow(
                id: "personalized-lock-ins",
                title: "Personalized lock-ins",
                subtitle: "Your first lock starts from the triggers, weak spots, and targets you named.",
                systemImage: "target"
            ),
            PersonalizedPlanRow(
                id: "weak-spot-protection",
                title: "Weak-spot protection",
                subtitle: "Lockd watches the moments where you usually fold, not just a daily app limit.",
                systemImage: "clock.badge.exclamationmark"
            ),
            PersonalizedPlanRow(
                id: "rescue-friction",
                title: "Rescue friction",
                subtitle: "Blocked moments become a recovery pause instead of a shame spiral.",
                systemImage: "hand.raised"
            ),
            PersonalizedPlanRow(
                id: "progress-feedback",
                title: "Progress feedback",
                subtitle: "Focus Score and recaps show what you protected, privately.",
                systemImage: "chart.line.uptrend.xyaxis"
            )
        ]
    }

    private var selectedAppTargetSummary: String {
        let titles = appTargetGroups
            .flatMap { $0.options }
            .filter { selectedAppTargetIDs.contains($0.id) }
            .map(\.title)

        if titles.isEmpty {
            return "Choose apps with Screen Time"
        }

        if titles.count <= 3 {
            return titles.joined(separator: ", ")
        }

        let visibleTitles = titles.prefix(3).joined(separator: ", ")
        return "\(visibleTitles) + \(titles.count - 3) more"
    }

    private var selectedAppTargetCount: Int {
        selectedAppTargetIDs.count
    }

    private func selectedCount(in group: OnboardingAppTargetGroup) -> Int {
        group.options.filter { selectedAppTargetIDs.contains($0.id) }.count
    }

    private func expandedBinding(for groupID: String) -> Binding<Bool> {
        Binding(
            get: { expandedAppTargetGroupIDs.contains(groupID) },
            set: { isExpanded in
                if isExpanded {
                    expandedAppTargetGroupIDs.insert(groupID)
                } else {
                    expandedAppTargetGroupIDs.remove(groupID)
                }
            }
        )
    }

    private var canAdvanceCurrentStep: Bool {
        guard !isPlanStep else {
            return true
        }

        let currentQuestion = questions[step]
        if currentQuestion.allowsMultipleSelection {
            return !selectedAppTargetIDs.isEmpty
        }

        return onboardingAnswers[currentQuestion.id] != nil
    }

    private var currentQuestionAllowsMultipleSelection: Bool {
        !isPlanStep && questions[step].allowsMultipleSelection
    }

    private var isPlanStep: Bool {
        step == questions.count
    }

    private var totalSteps: Int {
        questions.count + 1
    }
}
