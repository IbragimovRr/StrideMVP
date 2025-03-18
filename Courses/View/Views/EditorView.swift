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
        runJS("quill.root.innerHTML;") { r in
            handler(r)
        }
    }
    
    private func setHTML(_ value: String) {
        runJS("quill.clipboard.dangerouslyPasteHTML('\(value.escaped)');")
    }
    
    func setupSelection() {
        runJS("QuillFunctions.setupSelectionChangeHandler()")
    }
    
    func disableEditing() {
        runJS("quill.disable();")
    }
    
    func strikeThrough() {
        runJS("QuillFunctions.toggleStrike()")
    }
    
    func underline() {
        runJS("QuillFunctions.toggleUnderline()")
    }
    
    func bold() {
        runJS("QuillFunctions.toggleBold()")
    }
    
    func italic() {
        runJS("QuillFunctions.toggleItalic()")
    }
    
    func textColor(_ color: UIColor) {
        runJS("QuillFunctions.setTextColor('\(color.hex)')")
    }
    
    func font(_ name: String) {
        runJS("QuillFunctions.setFont('\(name)')")
    }
    
    func fontSize(_ size: Int) {
        runJS("QuillFunctions.setFontSize('\(size)')")
    }
    
    func heading(_ size: Int, _ fontName: String) {
        if size == 0 {
            runJS("QuillFunctions.removeHeading()")
        }else {
            runJS("QuillFunctions.setHeading('\(size)')")
        }
    }
    
    
    public func undo() {
        runJS("quill.history.undo();")
    }
    
    public func redo() {
        runJS("quill.history.redo();")
    }
    
    public func canUndo(handler: @escaping (Bool) -> Void) {
        runJS("QuillFunctions.canUndo();") { result in
            let canUndo = result == "true"
            handler(canUndo)
        }
    }
    
    public func canRedo(handler: @escaping (Bool) -> Void) {
        runJS("QuillFunctions.canRedo();") { result in
            let canRedo = result == "true"
            handler(canRedo)
        }
    }
    
    
    func hasChanges(handler: @escaping (Bool) -> Void) {
        runJS("QuillFunctions.hasChanges();") { result in
            let changes = result == "true"
            handler(changes)
        }
    }
    
    func resetChanges() {
        runJS("QuillFunctions.resetChanges();")
    }
    
    func justify(_ alignment: NSTextAlignment) {
        switch alignment {
        case .left:
            runJS("QuillFunctions.setAlignment('')")
        case .center:
            runJS("QuillFunctions.setAlignment('center')")
        case .right:
            runJS("QuillFunctions.setAlignment('right')")
        case .justified:
            runJS("QuillFunctions.setAlignment('justify')")
        case .natural:
            break
        @unknown default:
            break
        }
        
    }
    
    func insertImage(url: String, alt: String) {
        let escapedURL = url.escaped
        runJS("QuillFunctions.insertImage('\(escapedURL)')")
    }
    
    func blockquote() {
        runJS("QuillFunctions.setBlockquote();")
    }
    
    func setupImageClickHandler() {
        runJS("QuillFunctions.setupImageClickHandler();")
    }
    
    func initialFormat(message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any] {
            let isBold = messageBody["bold"] as? Bool ?? false
            let isItalic = messageBody["italic"] as? Bool ?? false
            let isUnderline = messageBody["underline"] as? Bool ?? false
            let isStrikethrough = messageBody["strike"] as? Bool ?? false
            let isBlockquote = messageBody["blockquote"] as? Bool ?? false
            let fontName = messageBody["font"] as? String ?? "Montserrat"
            let fontColor = messageBody["color"] as? String ?? ""
            let fontSize = messageBody["size"] as? String ?? "12pt"

            // Определение выравнивания
            var alignment: NSTextAlignment = .natural
            if let align = messageBody["align"] as? String {
                switch align {
                case "left":
                    alignment = .left
                case "center":
                    alignment = .center
                case "right":
                    alignment = .right
                case "justify":
                    alignment = .justified
                default:
                    alignment = .natural
                }
            }

            let cleanedFontName = fontName.replacingOccurrences(of: "\"", with: "")

            delegate?.format(isBold: isBold,isItalic: isItalic,isUnderline: isUnderline,isStrikethrough: isStrikethrough,isBlockquote: isBlockquote,aligment: alignment,fontName: cleanedFontName,fontColor: fontColor)
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
