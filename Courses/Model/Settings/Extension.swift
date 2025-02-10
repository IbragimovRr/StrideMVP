//
//  Extension.swift
//  Courses
//
//  Created by Руслан on 26.06.2024.
//

import UIKit

extension Data {
    func retrieveDataToString() -> NSAttributedString {
        let attributedString = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(self) as? NSAttributedString)!
        return attributedString
    }
}

extension UIImage {

    func scaleImage(toSize size: CGSize) -> UIImage {
        let newImage: UIImage
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: .zero, size: size))
        newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()

        return newImage
      }

    func withRoundedCorners(radius: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

}

extension UITextView {
    
    func convertUITextRangeToNSRange(range: UITextRange) -> NSRange {
        let beginning = self.beginningOfDocument
        let location = self.offset(from: beginning, to: range.start)
        let length = self.offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
    
    // Undo Redo
    func replaceRange(_ range: NSRange, withAttributedText text: NSAttributedString) {
         let previousText = attributedText.attributedSubstring(from: range)
         let previousSelectedRange = selectedRange

         undoManager?.registerUndo(withTarget: self, handler: { target in
             target.replaceRange(NSMakeRange(range.location, text.length),
                                 withAttributedText: previousText)
         })

         textStorage.replaceCharacters(in: range, with: text)
         selectedRange = NSMakeRange(previousSelectedRange.location, text.length)
     }
    
    func getURLs() -> [URL] {
        // Используйте регулярное выражение для поиска URL
        let pattern = "(https?://[\\w\\.-]+(/[\\w\\.-]+)+)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        // Извлечение URL из совпадений
        return matches.compactMap { match in
            let range = Range(match.range, in: text)!
            return URL(string: String(text[range]))
        }
    }



}



extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func strikeText() -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}

extension NSAttributedString {
    
    func htmlString() -> String? {
        let htmlData = try? self.data(from: NSRange(location: 0, length: self.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html])
        return String(data: htmlData ?? Data(), encoding: .utf8)
    }
}

extension String {

    var escaped: String {
        let unicode = self.unicodeScalars
        var newString = ""
        for char in unicode {
            if char.value == 39 || 
                char.value < 9 ||
                (char.value > 9 && char.value < 32)
            {
                let escaped = char.escaped(asASCII: true)
                newString.append(escaped)
            } else {
                newString.append(String(char))
            }
        }
        return newString
    }

}

extension UIColor {

    /// Hexadecimal representation of the UIColor.
    /// For example, UIColor.blackColor() becomes "#000000".
    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let r = Int(255.0 * red)
        let g = Int(255.0 * green)
        let b = Int(255.0 * blue)

        let str = String(format: "#%02x%02x%02x", r, g, b)
        return str
    }
}

extension UIView {
    
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurEffectView, at: 0)
    }
    
    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
}

extension TrainingItem {
    var toDictionary: [String: String] {
        return [
            "first_item": firstItemType?.rawValue ?? "",
            "first_data": firstItemData ?? "",
            "second_item": secondItemType?.rawValue ?? "",
            "second_data": secondItemData ?? ""
        ]
    }
    
    func toData() throws -> Data? {
        return try JSONSerialization.data(withJSONObject: self.toDictionary, options: .prettyPrinted)
    }
}

extension Date {
    func formattedDayMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}

extension UIView {
    func roundBottomCorners(radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}


extension UITextField {

    func scrollBottomText(scrollView: UIScrollView, notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let textFieldRect = self.convert(self.bounds, to: scrollView)
            let textFieldBottom = textFieldRect.maxY + 100

            let scrollY = textFieldBottom - keyboardHeight
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollY), animated: true)
        }
    }
}
