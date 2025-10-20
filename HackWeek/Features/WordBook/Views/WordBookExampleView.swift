//
//  WordBookExampleView.swift
//  HackWeek
//
//  Created by Stephen on 2025/10/14.
//

import SwiftUI
import SwiftData

/// 单词本功能示例视图
struct WordBookExampleView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var wordBookManager = WordBookManager.shared

    // MARK: - State
    @State private var showingAddWordSheet = false
    @State private var selectedImage: UIImage?
    @State private var newWord = ""
    @State private var selectedLanguage = "English"

    var body: some View {
        NavigationView {
            VStack {
                if wordBookManager.wordBooks.isEmpty {
                    emptyStateView
                } else {
                    wordBooksListView
                }
            }
            .navigationTitle("单词本")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加单词") {
                        showingAddWordSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddWordSheet) {
                AddWordSheet(
                    onAdd: { image, word, language in
                        addNewWord(image: image, word: word, language: language)
                    }
                )
            }
            .alert("错误", isPresented: .constant(wordBookManager.errorMessage != nil)) {
                Button("确定") {
                    wordBookManager.errorMessage = nil
                }
            } message: {
                if let errorMessage = wordBookManager.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("还没有单词")
                .font(.title2)
                .foregroundColor(.gray)

            Text("点击右上角的\"添加单词\"开始学习")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("添加第一个单词") {
                showingAddWordSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Word Books List View
    private var wordBooksListView: some View {
        List {
            ForEach(wordBookManager.wordBooks, id: \.id) { wordBook in
                NavigationLink(destination: WordDetailView(wordBook: wordBook)) {
                    WordBookRowView(wordBook: wordBook)
                }
            }
            .onDelete(perform: deleteWordBooks)
        }
        .refreshable {
            wordBookManager.getWordBooks()
        }
    }

    // MARK: - Methods
    private func addNewWord(image: UIImage, word: String, language: String) {
        let success = wordBookManager.createWord(
            image: image,
            targetLanguage: language,
            word: word
        ) != nil

        if success {
            print("✅ 成功添加单词: \(word)")
        } else {
            print("❌ 添加单词失败: \(word)")
        }
    }

    private func deleteWordBooks(at offsets: IndexSet) {
        for index in offsets {
            let wordBook = wordBookManager.wordBooks[index]
            wordBookManager.deleteWordBook(wordBook)
        }
    }
}

// MARK: - Word Book Row View
struct WordBookRowView: View {
    let wordBook: WordBook

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(wordBook.friendlyDateDisplay)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("\(wordBook.wordCount) 个单词")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Word Detail View
struct WordDetailView: View {
    let wordBook: WordBook
    @StateObject private var wordBookManager = WordBookManager.shared
    @State private var words: [WordModel] = []

    var body: some View {
        List {
            ForEach(words, id: \.id) { word in
                WordRowView(word: word) {
                    updateWordMastery(word)
                }
            }
            .onDelete(perform: deleteWords)
        }
        .navigationTitle(wordBook.friendlyDateDisplay)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadWords()
        }
        .refreshable {
            loadWords()
        }
    }

    private func loadWords() {
        words = wordBookManager.getWords(forWordBookId: wordBook.id)
    }

    private func updateWordMastery(_ word: WordModel) {
        wordBookManager.updateWordMasteryLevel(word, to: word.masteryLevel + 1)
        loadWords() // 重新加载数据
    }

    private func deleteWords(at offsets: IndexSet) {
        for index in offsets {
            let word = words[index]
            wordBookManager.deleteWord(word)
        }
        loadWords() // 重新加载数据
    }
}

// MARK: - Word Row View
struct WordRowView: View {
    let word: WordModel
    let onUpdateMastery: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 图片
            if let uiImage = word.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(word.targetLanguage)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(word.masteryLevelDescription)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(masteryLevelColor.opacity(0.2))
                    .foregroundColor(masteryLevelColor)
                    .cornerRadius(4)
            }

            Spacer()

            // 掌握程度按钮
            Button(action: onUpdateMastery) {
                VStack(spacing: 2) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("升级")
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }

    private var masteryLevelColor: Color {
        switch word.masteryLevel {
        case 0: return .gray
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return .gray
        }
    }
}

// MARK: - Add Word Sheet
struct AddWordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var wordText = ""
    @State private var selectedLanguage = "English"

    let onAdd: (UIImage, String, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("选择图片") {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }

                    Button("选择图片") {
                        // 这里应该调用图片选择器
                        // 为了演示，我们使用一个示例图片
                        selectedImage = createSampleImage()
                    }
                }

                Section("单词信息") {
                    TextField("输入单词", text: $wordText)

                    Picker("语言", selection: $selectedLanguage) {
                        Text("English").tag("English")
                        Text("中文").tag("中文")
                        Text("日本語").tag("日本語")
                        Text("한국어").tag("한국어")
                    }
                }
            }
            .navigationTitle("添加单词")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        if let image = selectedImage, !wordText.isEmpty {
                            onAdd(image, wordText, selectedLanguage)
                            dismiss()
                        }
                    }
                    .disabled(selectedImage == nil || wordText.isEmpty)
                }
            }
        }
    }

    private func createSampleImage() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let text = "示例图片"
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

// MARK: - Preview
#Preview {
    // 注意：这里无法直接预览，因为需要 ModelContainer
    // 在实际使用时，需要在父视图中提供 .modelContainer()
    Text("单词本示例视图")
}