//
//  EditorController.swift
//  TestEditor
//
//  Created by poisson florent on 03/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit
import SwiftyAttributes

class EditorController: UIViewController {

    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var sourceTextView: UITextView!
    @IBOutlet weak var overlayTextView: UITextView!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var logTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    
    private var cursorLineContainer: UIView!
    private let cursorLineView = UIView()
    private var cursorLineTop: NSLayoutConstraint!
    private var cursorLineHeight: NSLayoutConstraint!
    
    private lazy var logViewHeight = self.view.bounds.height/3
    
    var moduleFile: ModuleFile!
    var script: Script!
    var isImmutable: Bool = false
    var theme: Theme = Theme.dark
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        customize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForNotifications()
        
        startObservingKeyboard()

        // Display script
        
        // Fix for initializing text view with the font
        sourceTextView.attributedText = " ".withFont(theme.font)

        updateSyntaxColor()

        DispatchQueue.main.async {
            self.updateSyntaxOverlay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.script.characters.isEmpty {
            self.sourceTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isImmutable {
            saveScript(silently: true)
        }
        
        unregisterForNotifications()
        
        stopObservingKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func customize() {
        logTextViewHeight.constant = logViewHeight
        
        // Editor theming
        view.backgroundColor = Theme.dark.backgroundColor
        sourceTextView.backgroundColor = Theme.dark.backgroundColor
        sourceTextView.textColor = Theme.dark.textColor
        
        // Cursor line view setup
        cursorLineContainer = UIView(frame: overlayTextView.bounds)
        cursorLineContainer.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cursorLineContainer.backgroundColor = .clear
        cursorLineContainer.isUserInteractionEnabled = false
        overlayTextView.addSubview(cursorLineContainer)

        cursorLineView.backgroundColor = UIColor(hexString: "#E7AF1F").withAlphaComponent(0.15)
        cursorLineView.translatesAutoresizingMaskIntoConstraints = false
        overlayTextView.addSubview(cursorLineView)
        cursorLineTop = cursorLineView
            .topAnchor
            .constraint(equalTo: cursorLineContainer.topAnchor, constant: sourceTextView.layoutMargins.top)
        cursorLineHeight = cursorLineView.heightAnchor.constraint(equalToConstant: Theme.dark.font.lineHeight) // Default size
        NSLayoutConstraint.activate([
            cursorLineTop,
            cursorLineView.leftAnchor.constraint(equalTo: cursorLineContainer.leftAnchor),
            cursorLineView.rightAnchor.constraint(equalTo: cursorLineContainer.rightAnchor),
            cursorLineHeight
            ])
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(forName: printNotification,
                                               object: nil,
                                               queue: nil) {
                                                [weak self] (notification) in
                                                if let message = notification.userInfo?[notificationMessageInfosKey] as? String {
                                                    self?.displayLog(message: message)
                                                }
        }
    }
    
    private func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - State management
    
    private func updateSyntaxColor() {
        if let colorizedScript = try? SyntaxHighlighter.colorizeScript(script: script.string, theme: Theme.dark) {
            sourceTextView.attributedText = colorizedScript
        } else {
            sourceTextView.text = script.string
        }
    }
    
    private func updateSyntaxOverlay() {
        let selectedRange = sourceTextView.selectedRange
        let currentLine = script.getLineIndex(forCursorPosition: selectedRange.location)
        let font = Theme.dark.font
        let lineHeight = (font.lineHeight + font.leading)
        let layoutManager = sourceTextView.layoutManager

        // Compute line numbers & line cursor position
        let lineIndexes = NSMutableAttributedString()
        var lineCursorYPosition: CGFloat = 0
        var lineCursorHeight: CGFloat = 0

        for (index, line) in script.lines.enumerated() {
            
            let glyphRange = layoutManager.glyphRange(forCharacterRange: line,
                                                     actualCharacterRange: nil)
            let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange,
                                                          in: layoutManager.textContainers[0])
            var viewLineCount = Int(ceil(boundingRect.height / lineHeight))

            // Line n-1 fix
            if index == script.lines.count - 2,
                line.location + line.length >= script.characters.count,
                viewLineCount > 1 {
                viewLineCount -= 1
            }
            
            let displayedIndex = index + 1
            var lineIndex = String(format: (displayedIndex < 100 ? "%02d" : "%03d"), displayedIndex) + "\n"
            for _ in 0..<viewLineCount-1 {
                lineIndex += "\n"
            }
            let color: UIColor = (index == currentLine ?
                Theme.dark.selectedLineNumberColor :
                Theme.dark.defaultLineNumberColor)
            lineIndexes.append(lineIndex
                .withFont(Theme.dark.font)
                .withTextColor(color))

            // Compute line cursor position
            let displayedLineHeight = CGFloat(viewLineCount) * lineHeight
            if index <= currentLine {
                if index == currentLine {
                    lineCursorHeight = displayedLineHeight
                } else {
                    lineCursorYPosition += displayedLineHeight
                }
            }
        }
        
        overlayTextView.attributedText = lineIndexes
        
        // Update line cursor position
        cursorLineTop.constant = sourceTextView.layoutMargins.top + lineCursorYPosition
        cursorLineHeight.constant = lineCursorHeight
        overlayTextView.layoutIfNeeded()
    }
    
    private func runScript(_ script: String) {
        runButton.isEnabled = false
        logTextView.text = nil
        view.endEditing(true)

        let lexer = Lexer(script: script)
        let parser = Parser(with: lexer)
        do {
            if let program = try parser.parseProgram() {
                displayLog(message: "------------- parsing OK -----------\n")
                try program.perform()
                displayLog(message: "\n------------- perform OK -----------")
            }
            
        } catch let error {
            displayLog(message: "Error: \(error)")
        }
        
        runButton.isEnabled = true
    }
    
    private func displayLog(message: String) {
        let text = (logTextView.text ?? "") + "\n" + message
        logTextView.text = text
    }
    
    private func displayLineAlert(lineNumber: Int, errorPosition: Int) {
        // TODO:
        // ...
    }
    
    private func saveScript(silently: Bool = false) {
        do {
            try moduleFile.save(script: script)
        } catch let error {
            if !silently {
                displayError(title: NSLocalizedString("Module script saving error!", comment: ""),
                             message: NSLocalizedString("Module script saving failed with error: \(error.localizedDescription)",
                                comment: ""))
            }
        }
    }
    
    private func displayError(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                     style: .cancel,
                                     handler: nil)
        alertController.addAction(okAction)
        
        present(alertController,
                animated: true,
                completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        sender.isEnabled = false
        saveScript()
    }
    
    @IBAction func runButtonTapped(sender: UIButton) {
        if let script = sourceTextView.text {
            runScript(script + "\n")
        }
    }
    
    @IBAction func helpButtonTapped(sender: UIBarButtonItem) {
        presentHelpController()
    }

    // MARK: - Navigation
    
    private func presentHelpController() {
        let helpNavController = storyboard?.instantiateViewController(withIdentifier: "HelpNavigationController")
        present(helpNavController!,
                animated: true,
                completion: nil)
    }

}

// MARK: - KeyboardObserverDelegate
extension EditorController: KeyboardObserverDelegate {
    
    func keyboardWillMove(to height: CGFloat, with duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            let height = (height <= 0 ? self.logViewHeight : height)
            self.logTextViewHeight.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardDidHide() {
        // ...
    }
    
}

// MARK: - UITextViewDelegate
extension EditorController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let selectedRange = textView.selectedRange

        // Remove dot automatically generated by text input
        // see behavior activated by os user setting in:
        //    Settings > General > Keyboard > "." Shortcut
        let filteredString = textView
            .attributedText
            .string
            .replacingOccurrences(of: ". ", with: "  ")
        
        script = Script(string: filteredString)
        saveButton.isEnabled = !isImmutable
        updateSyntaxColor()
        updateSyntaxOverlay()
        textView.selectedRange = selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        updateSyntaxOverlay()
    }
    
}

extension EditorController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        overlayTextView.contentOffset = scrollView.contentOffset
    }
    
}

