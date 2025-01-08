import UIKit
import SwiftyMarkdown

class MarkdownTextView: UITextView {

    // MARK: - Properties

    private var markdownText: String = ""

    var onTextChange: ((String) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        delegate = self
        font = UIFont.systemFont(ofSize: 16)
        isEditable = true
        isSelectable = true
        isScrollEnabled = true
    }

    // MARK: - Public Methods

    func setMarkdown(_ markdown: String) {
        markdownText = markdown
        updateAttributedText()
    }

    func getMarkdown() -> String {
        return markdownText
    }

    func toggleBoldOnSelection() {
        applyFormatting("**", toSelection: true)
    }
    
    func toggleItalicOnSelection() {
       applyFormatting("*", toSelection: true)
    }
    
    func toggleHeadingOnSelection() {
        applyFormatting("# ", toSelection: false)
    }
    
    func toggleListOnSelection() {
        applyFormatting("* ", toSelection: false)
    }
    
    func addLinkOnSelection(url: String) {
        applyLinkFormatting(url: url)
    }

    // MARK: - Private Methods
    
    private func applyFormatting(_ format: String, toSelection: Bool) {
           guard let selectedRange = selectedTextRange,
                 let selectedText = text(in: selectedRange)
            else { return }
            
           let formattedText = toSelection ? "\(format)\(selectedText)\(format)" : format + selectedText
            replace(selectedRange, withText: formattedText)
            markdownText = text
           updateAttributedText()
    }
    
    private func applyLinkFormatting(url: String) {
        guard let selectedRange = selectedTextRange,
              let selectedText = text(in: selectedRange) else { return }

        let formattedText = "[\(selectedText)](\(url))"
        replace(selectedRange, withText: formattedText)
        markdownText = text
        updateAttributedText()
    }

    func updateAttributedText() {
        let markdown = SwiftyMarkdown(string: markdownText)
        self.attributedText = markdown.attributedString()
    }
    
}

// MARK: - UITextViewDelegate

extension MarkdownTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        markdownText = textView.text
        updateAttributedText()
        onTextChange?(markdownText)
    }
}
