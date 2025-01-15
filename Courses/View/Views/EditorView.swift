import UIKit
import WebKit

protocol EditorViewDelegate {
    func format(isBold: Bool, isItalic: Bool, isUnderline: Bool, isStrikethrough: Bool, isBlockquote: Bool, aligment: NSTextAlignment)
}

class EditorView: WKWebView {
    
    
    public var html: String = "" {
        didSet {
            setHTML(html)
        }
    }
    
    var delegate: EditorViewDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override var inputAccessoryView: UIView? {
        return nil
    }
    
    // MARK: - Setup
    
    private func setup() {
        backgroundColor = .clear
        isOpaque = false
        translatesAutoresizingMaskIntoConstraints = false
        loadEditorHTML()
    }
    
    private func loadEditorHTML() {
        guard let url = Bundle.main.url(forResource: "rich_editor", withExtension: "html") else { return }
        loadFileURL(url, allowingReadAccessTo: url)
    }
    
    public func getHtml(handler: @escaping (String) -> Void) {
        runJS("RE.getHtml()") { r in
            handler(r)
        }
    }
    
    private func setHTML(_ value: String) {
        runJS("RE.setHtml('\(value.escaped)')")
    }
    
    func strikeThrough() {
        evaluateJavaScript("RE.setStrikeThrough()")
    }
    
    func underline() {
        evaluateJavaScript("RE.setUnderline()")
    }
    
    func bold() {
        runJS("RE.setBold()")
    }
    
    func italic() {
        runJS("RE.setItalic()")
    }
    
    func textColor(_ color: UIColor) {
        runJS("RE.prepareInsert()")
        runJS("RE.setTextColor('\(color.hex)')")
    }
    
//    func editorFontColor(_ color: UIColor) {
//        runJS("RE.setBaseTextColor('\(color.hex)')")
//    }
    
    func horizontalRule() {
        runJS("RE.horizontalRule()")
    }
    
    func textBackgroundColor(_ color: UIColor) {
        runJS("RE.prepareInsert()")
        runJS("RE.setTextBackgroundColor('\(color.hex)')")
    }
    
    func font(_ name: String) {
        runJS("RE.setFont('\(name)')")
    }
    
    func fontSize(_ size: Int) {
        runJS("RE.setFontSize('\(size)px')")
    }
    
    func heading(_ size: Int) {
        runJS("RE.setHeading('\(size)')")
    }
    
    func heading(heading: Int) {
        evaluateJavaScript("RE.setHeading(\(heading))")
    }
    
    public func undo() {
        runJS("RE.undo()")
    }
    
    public func redo() {
        runJS("RE.redo()")
    }
    
    func justify(_ alignment: NSTextAlignment) {
        switch alignment {
        case .left:
            evaluateJavaScript("RE.setJustifyLeft()")
        case .center:
            evaluateJavaScript("RE.setJustifyCenter()")
        case .right:
            evaluateJavaScript("RE.setJustifyRight()")
        case .justified:
            evaluateJavaScript("RE.setJustifyFull()")
        case .natural:
            break
        @unknown default:
            break
        }
        
    }
    
    func getFormat() {
        runJS("RE.isCommandActive('bold');") { result in
            print(result)
        }
    }
    
    // Не работает
    public func checkbox() {
        evaluateJavaScript("RE.setCheckbox('\(UUID().uuidString.prefix(8))')")
    }
    
    
    func getLineHeight(completion: @escaping (String?) -> Void) {
        evaluateJavaScript("RE.getLineHeight()") { (result, error) in
            if let error = error {
                print("Error getting line height: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(result as? String)
        }
    }
    
    func lineHeight(height: String) {
        evaluateJavaScript("RE.setLineHeight('\(height)')")
    }
    
    func insertSpinner() {
        runJS("RE.showSpinner()")
    }
    
    func insertImage(url: String, alt: String, width: Int, height: Int) {
        let escapedURL = url
        let escapedAlt = alt
        
        evaluateJavaScript("RE.insertImage('\(escapedURL)', '\(escapedAlt)', '\(width)', '\(height)')")
    }
    
    func blockquote() {
        evaluateJavaScript("RE.setBlockquote()")
    }
    
    func insertTable(width: Int = 2, height: Int = 2) {
        runJS("RE.prepareInsert()")
        runJS("RE.insertTable(\(width), \(height))")
    }
    
    func insertHTML(html: String) {
        evaluateJavaScript("RE.insertHTML('\(html)')")
    }
    
    func insertLink(url: String, title: String) {
        evaluateJavaScript("RE.insertLink('\(url)', '\(title)')")
    }
    
    func prepareInsert() {
        evaluateJavaScript("RE.prepareInsert()")
    }
    
    func focus() {
        evaluateJavaScript("RE.focus()")
    }
    
    func initialFormat(message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any] {
            if let formattingData = messageBody["formatting"] as? [String: Bool] {
                let isBold = formattingData["bold"] ?? false
                let isItalic = formattingData["italic"] ?? false
                let isUnderline = formattingData["underline"] ?? false
                let isStrikethrough = formattingData["strikethrough"] ?? false
                let isBlockquote = formattingData["blockquote"] ?? false
                let isJustifyLeft = formattingData["justifyLeft"] ?? false
                let isJustifyCenter = formattingData["justifyCenter"] ?? false
                let isJustifyRight = formattingData["justifyRight"] ?? false
                let isJustifyFull = formattingData["justifyFull"] ?? false
                
                var alignment: NSTextAlignment = .natural
                if isJustifyLeft {
                    alignment = .left
                } else if isJustifyCenter {
                    alignment = .center
                } else if isJustifyRight {
                    alignment = .right
                } else if isJustifyFull {
                    alignment = .justified
                }
                
                delegate?.format(isBold: isBold, isItalic: isItalic, isUnderline: isUnderline, isStrikethrough: isStrikethrough, isBlockquote: isBlockquote, aligment: alignment)
            }
        }
    }
    
    func getEditorContent(completion: @escaping (String?) -> Void) {
        evaluateJavaScript("RE.getHtml()") { (result, error) in
            if let error = error {
                print("Error getting content: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(result as? String)
        }
    }
    
    
    public func runJS(_ js: String, handler: ((String) -> Void)? = nil) {
        evaluateJavaScript(js) {(result, error) in
            if let error = error {
                print("WKWebViewJavascriptBridge Error: \(String(describing: error)) - JS: \(js)")
                handler?("")
                return
            }
            
            guard let handler = handler else { return }
            if let resultBool = result as? Bool {
                handler(resultBool ? "true" : "false")
                return
            }
            if let resultInt = result as? Int {
                handler("\(resultInt)")
                return
            }
            if let resultStr = result as? String {
                handler(resultStr)
                return
            }
            handler("")
        }
    }
}
