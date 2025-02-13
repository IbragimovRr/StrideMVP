import UIKit
import WebKit

protocol EditorViewDelegate {
    func format(isBold: Bool, isItalic: Bool, isUnderline: Bool, isStrikethrough: Bool, isBlockquote: Bool, aligment: NSTextAlignment, fontName:String, fontColor: String)
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
        scrollView.isScrollEnabled = false
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
    
    func disableEditing() {
        runJS("RE.disableEditing()")
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
    
    func heading(_ size: Int, _ fontName: String) {
        if size == 0 {
            runJS("RE.resetHeading()")
        }else {
            runJS("RE.setHeading('\(size)', '\(fontName)')")
        }
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
    

    func scrollTop() {
        runJS("RE.scrollTop();")
    }
    
    func insertImage(url: String, alt: String) {
        let escapedURL = url.escaped
        let escapedAlt = alt.escaped
        
        evaluateJavaScript("RE.insertImage('\(escapedURL)', '\(escapedAlt)')")
    }
    
    func blockquote() {
        evaluateJavaScript("RE.setBlockquote();")
    }
    
    func insertTable(width: Int = 2, height: Int = 2) {
        runJS("RE.prepareInsert()")
        runJS("RE.insertTable(\(width), \(height))")
    }
    
    func insertHTML(html: String) {
        runJS("RE.insertHTML('\(html)')")
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
    
    func unFocus() {
        evaluateJavaScript("RE.blurFocus()")
    }
    
    
    func initialFormat(message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any] {

            if let formattingData = messageBody["formatting"] as? [String: Any] {
                let isBold = formattingData["bold"] as? Bool ?? false
                let isItalic = formattingData["italic"] as? Bool ?? false
                let isUnderline = formattingData["underline"] as? Bool ?? false
                let isStrikethrough = formattingData["strikethrough"] as? Bool ?? false
                let isBlockquote = formattingData["blockquote"] as? Bool ?? false
                let isJustifyLeft = formattingData["justifyLeft"] as? Bool ?? false
                let isJustifyCenter = formattingData["justifyCenter"] as? Bool ?? false
                let isJustifyRight = formattingData["justifyRight"] as? Bool ?? false
                let isJustifyFull = formattingData["justifyFull"] as? Bool ?? false
                var fontName = formattingData["fontName"] as? String ?? "Times New Roman"
                let fontColor = formattingData["fontColor"] as? String ?? ""
                
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

                fontName = fontName.replacingOccurrences(of: "\"", with: "")

                delegate?.format(isBold: isBold, isItalic: isItalic, isUnderline: isUnderline, isStrikethrough: isStrikethrough, isBlockquote: isBlockquote, aligment: alignment, fontName: fontName, fontColor: fontColor)
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
