// The Swift Programming Language
// https://docs.swift.org/swift-book
import PDFKit

public class GLPDFKit {
    let fileURL: URL
    var document: PDFDocument?
    
    public init(_ file: URL) {
        self.fileURL = file 
        self.load()
    }
    
    public func load() {
        self.document = PDFDocument(url: fileURL)
    }
    
    public var pageCount: Int {
        document?.pageCount ?? 0
    }

    @discardableResult
    public func pageTextContentMap(_ transform: (String) -> Void) {
        guard let document = self.document else {
            return
        }
        for i in 0..<document.pageCount {
            let content = document.page(at: i)?.string
            transform(content ?? "")
        }
    }
    
    public func allTextContent() -> String {
        return document?.string ?? ""
    }
}

