//
//  MainAppView.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import SwiftUI

/// 主应用界面Props
struct MainAppViewProps {
    var onSettings: (() -> Void)?
}

/// 主应用界面
struct MainAppView: ComposablePageComponent {
    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = MainAppViewProps

    let props: ComponentProps

    init(props: ComponentProps = MainAppViewProps()) {
        self.props = props
    }

    var pageName: String { "main_app" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_FROM: "main",
            .TRACK_KEY_TYPE: "home"
        ]
    }

    // MARK: - State Variables
    @StateObject private var wordBookManager = WordBookManager.shared
    @State private var hasSurveyChecked = false // 确保只检查一次
    
    // MARK: - Environment
    @Environment(\.tracking) private var tracking

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 问候和汇总区域
                    VStack(spacing: 16) {
                        // 问候文本
                        Text(greetingText)
                            .font(.title3)
                            .foregroundColor(.primary)

                        // 总单词数
                        Text("\(totalWordCount) words collected")
                            .font(.title)
                            .fontWeight(.semibold)

                        // 拍照按钮区域
                        Button(action: {
                            Navigator.present(CameraPage(), from: "main_app")
                        }) {
                            VStack(spacing: 16) {
                                // 圆形相机按钮
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 120)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)

                                Text("拍照学单词")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)

                    // 按日期分组的单词条目
                    if groupedWordBooks.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(groupedWordBooks.keys.sorted(by: >), id: \.self) { date in
                                if let wordBooks = groupedWordBooks[date] {
                                    DailyWordSection(
                                        date: date,
                                        wordBooks: wordBooks,
                                        onTap: {
                                            Navigator.present(
                                                WordBookPage(),
                                                from: "main_app"
                                            )
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 左侧：Welcome 测试按钮
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showWelcomePage()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.wave.fill")
                                .font(.body)
                            Text("Welcome")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // 右侧：设置按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        TemplateAPI.Navigator.openSettings("main")
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                _ = wordBookManager.getWordBooks()
                checkAndShowSurvey()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                _ = wordBookManager.getWordBooks()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Welcome Page Methods
    
    /// 展示欢迎页面
    private func showWelcomePage() {
        // 埋点：点击测试入口
        tracking("main_welcome_test_click", [
            "type": "test",
            "from": "main_app"
        ])
        
        // 使用 present 模态展示欢迎页
        TemplateAPI.Navigator.present(
            WelcomePage(props: WelcomePageProps(onDismiss: {
                // 页面消失时执行
                TemplateAPI.Navigator.dismiss(true)
            })),
            from: "main_app",
            animated: true
        )
    }
    
    // MARK: - Survey Methods
    
    /// 检查并展示问卷
    private func checkAndShowSurvey() {
        // 确保只检查一次
        guard !hasSurveyChecked else { return }
        hasSurveyChecked = true
        
        // 检查是否需要展示问卷
        guard SurveyFatigueManager.shared.shouldShowSurvey() else {
            return
        }
        
        // 延迟展示，避免与其他启动逻辑冲突
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSurvey()
        }
    }
    
    /// 展示问卷
    private func showSurvey() {
        let surveyType = SurveyFatigueManager.shared.getCurrentSurveyType()
        
        Navigator.present(
            TrialCancelSurveyPage(
                props: TrialCancelSurveyPageProps(
                    surveyType: surveyType,
                    onDismiss: nil
                )
            ),
            from: "main_app"
        )
    }
    
    // MARK: - Computed Properties
    private var greetingText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let dateString = formatter.string(from: Date())

        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String

        switch hour {
        case 6..<12:
            timeOfDay = "Good Morning!"
        case 12..<17:
            timeOfDay = "Good Afternoon!"
        case 17..<22:
            timeOfDay = "Good Evening!"
        default:
            timeOfDay = "Good Night!"
        }

        return "\(dateString), \(timeOfDay)"
    }

    private var totalWordCount: Int {
        wordBookManager.wordBooks.reduce(0) { total, wordBook in
            total + wordBook.wordCount
        }
    }

    private var groupedWordBooks: [Date: [WordBook]] {
        Dictionary(grouping: wordBookManager.wordBooks) { wordBook in
            Calendar.current.startOfDay(for: wordBook.recordDate)
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.6))

            Text("还没有单词")
                .font(.headline)
                .foregroundColor(.gray)

            Text("点击上方区域开始拍照学单词")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Daily Word Section
struct DailyWordSection: View {
    let date: Date
    let wordBooks: [WordBook]
    let onTap: () -> Void // 改为无参数的回调

    // 获取该日期下所有单词，最多5个
    private var allWords: [WordModel] {
        let words = wordBooks.flatMap { $0.words }
        return Array(words.prefix(5))
    }

    private var totalWords: Int {
        wordBooks.reduce(0) { total, wordBook in
            total + wordBook.wordCount
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // 日期和单词数量标题
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text(dateString)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("\(totalWords) words")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }

                // 单词缩略图网格 - 显示该日期下所有单词，最多5个
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                    ForEach(allWords, id: \.id) { word in
                        WordImageThumbnail(word: word)
                    }

                    // 如果单词数量少于5个，用空位补齐
                    ForEach(allWords.count..<5, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 60, height: 60)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Word Image Thumbnail
struct WordImageThumbnail: View {
    let word: WordModel

    var body: some View {
        if let uiImage = word.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 2)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                )
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .frame(width: 60, height: 60)
                .overlay(
                    VStack(spacing: 2) {
                        Image(systemName: "photo")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Word Thumbnail (保留原组件以备后用)
struct WordThumbnail: View {
    let wordBook: WordBook
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            if let firstWord = wordBook.words.first,
               let uiImage = firstWord.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 2)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(width: 70, height: 70)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("无图片")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: UUID())
    }
}


#Preview {
    MainAppView()
}
