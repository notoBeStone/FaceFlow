//
//  WordBookPage.swift
//  HackWords
//
//  Created by Claude on 2025/10/14.
//

import SwiftUI

/// 单词本学习页面 - 按照Figma设计实现
struct WordBookPage: View, GLSwiftUIPageTrackable {
    var trackerPageName: String? = "word_book_page"
    var trackerPageParams: [String: Any]? = [:]

    @StateObject private var wordBookManager = WordBookManager.shared
    @State private var currentWordIndex = 0
    @State private var isCompleted = false

    // 按熟练度排序后的单词列表（从低到高）
    private var sortedWords: [WordModel] {
        let allWords = wordBookManager.wordBooks.flatMap { $0.words }
        return allWords.sorted { $0.masteryLevel < $1.masteryLevel }
    }

    var body: some View {
        ZStack {
            // 白色背景
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if sortedWords.isEmpty {
                    emptyStateView
                } else if isCompleted {
                    completionView
                } else {
                    learningView
                }
            }
        }
        .onAppear {
            loadWords()
        }
    }

    func onFirstAppear() {
        debugPrint("Word book page appeared")
    }

    func onPageExit() {
        debugPrint("Word book page exited")
    }

    // MARK: - Views

    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("单词本为空")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.black)

            Text("拍照识别一些单词来开始学习吧")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: {
                TemplateAPI.Navigator.dismiss()
            }) {
                Text("返回")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(Color.gray)
                    .cornerRadius(22)
            }

            Spacer()
        }
    }

    /// 完成视图
    private var completionView: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("全部完成！")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.black)

            Text("今天的单词已经全部复习完成")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: {
                debugPrint("🔙 完成页面返回按钮被点击")
                TemplateAPI.Navigator.dismiss()
            }) {
                Text("返回")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(Color.gray)
                    .cornerRadius(22)
            }

            Spacer()
        }
    }

    /// 学习视图 - 按照Figma设计
    private var learningView: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 顶部返回按钮 - 考虑安全区域
                HStack {
                    Button(action: {
                        TemplateAPI.Navigator.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16))
                            Text("Back")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }

                    Spacer()
                }
                .padding(.leading, 22)
                .padding(.top, geometry.safeAreaInsets.top + 10)
                .padding(.bottom, 10)

                Spacer()

                // 中间内容区域
                if currentWordIndex < sortedWords.count {
                    let currentWord = sortedWords[currentWordIndex]

                    VStack(spacing: 20) {
                        // 单词图片
                        if let uiImage = currentWord.uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 215, height: 215)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        } else {
                            Rectangle()
                                .fill(Color(.systemGray6))
                                .frame(width: 215, height: 215)
                                .cornerRadius(12)
                        }

                        // 单词文本
                        Text(currentWord.word)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }

                Spacer()

                // 底部操作按钮
                if currentWordIndex < sortedWords.count {
                    HStack(spacing: 84) {
                        // 错误按钮 (❌)
                        Button(action: {
                            markWordAsIncorrect()
                        }) {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 78, height: 78)
                                .overlay(
                                    Text("❌")
                                        .font(.system(size: 26))
                                )
                        }

                        // 正确按钮 (☑️)
                        Button(action: {
                            markWordAsCorrect()
                        }) {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 78, height: 78)
                                .overlay(
                                    Text("☑️")
                                        .font(.system(size: 26))
                                )
                        }
                    }
                    .padding(.bottom, max(67, geometry.safeAreaInsets.bottom + 20))
                }
            }
        }
    }

    // MARK: - Actions

    /// 加载单词
    private func loadWords() {
        _ = wordBookManager.getWordBooks()
        currentWordIndex = 0
        isCompleted = sortedWords.isEmpty
        debugPrint("📚 加载了 \(sortedWords.count) 个单词进行学习")
        for (index, word) in sortedWords.enumerated() {
            debugPrint("单词 \(index + 1): \(word.word) (熟练度: \(word.masteryLevel))")
        }
    }

    /// 标记单词为不认识
    private func markWordAsIncorrect() {
        guard currentWordIndex < sortedWords.count else { return }

        let currentWord = sortedWords[currentWordIndex]
        wordBookManager.markWordReviewed(currentWord, correct: false)

        moveToNextWord()
    }

    /// 标记单词为认识
    private func markWordAsCorrect() {
        guard currentWordIndex < sortedWords.count else { return }

        let currentWord = sortedWords[currentWordIndex]
        wordBookManager.markWordReviewed(currentWord, correct: true)

        moveToNextWord()
    }

    /// 移动到下一个单词
    private func moveToNextWord() {
        currentWordIndex += 1
        debugPrint("📖 移动到下一个单词，索引: \(currentWordIndex)，总数: \(sortedWords.count)")

        if currentWordIndex >= sortedWords.count {
            // 所有单词已完成
            isCompleted = true
            debugPrint("🎉 所有单词已完成，显示完成页面")
        }
    }
}

#Preview {
    WordBookPage()
}