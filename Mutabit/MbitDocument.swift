import Cocoa


class MbitDocument: NSDocument {
    @IBOutlet weak var inputTextView: NSTextView!
    @IBOutlet weak var outputTextView: NSTextView!
    @IBOutlet weak var promptTextView: NSTextView!
    @IBOutlet weak var scriptTextView: NSTextView!
    @IBOutlet weak var runButton: NSButton!
    
    private var isNewDocument = true
    private var pythonRunner: PythonRunner?
    
    private var appDelegate: AppDelegate {
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else {
            fatalError("App delegate is not of type AppDelegate")
        }
        return delegate
    }

    override init() {
        super.init()
        isNewDocument = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willStartRunningScript(_:)),
            name: PythonRunnerWillStartRunningNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinishRunningScript(_:)),
            name: PythonRunnerDidFinishRunningNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureTextView(_ textView: NSTextView) {
        guard let textStorage = textView.textStorage else {
            fatalError("Unable to get text storage from text view")
        }
        let fullRange = NSRange(location: 0, length: textStorage.length)
        textStorage.setAttributes(appDelegate.textAttributes, range: fullRange)
        
        textView.typingAttributes = appDelegate.textAttributes
    }
    
    @IBAction func runScript(_ runButton: NSButton) {
        pythonRunner = PythonRunner(input: inputTextView.string, script: scriptTextView.string)
        pythonRunner?.startRunning()
    }
    
    private func updateOutputTextView(with string: String) {
        if let textStorage = outputTextView.textStorage {
            let attributedString = NSAttributedString(
                string: string,
                attributes: appDelegate.textAttributes
            )
            textStorage.replaceCharacters(in: NSRange(location: 0, length: textStorage.length),
                                        with: attributedString)
        }
    }
    
    @objc private func willStartRunningScript(_ notification: Notification) {
        Swift.print("Will start running script")
        updateOutputTextView(with: "")
    }
    
    @objc private func didFinishRunningScript(_ notification: Notification) {
        Swift.print("Did finish running script")
        if let error = notification.userInfo?[PythonRunnerErrorKey] as? Error {
            Swift.print("Error running script: \(error)")
        } else {
            let pythonRunner = notification.object as! PythonRunner
            if let output = pythonRunner.output {
                updateOutputTextView(with: output)
            }
        }
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("MbitDocument")
    }

    override func data(ofType typeName: String) throws -> Data {
        let xml = """
        <?xml version='1.0' encoding='utf-8'?>
        <!DOCTYPE mutabit SYSTEM 'https://donm.cc/dtds/mutabit.dtd'>
        <mutabit version='1.0'>
            <input format='csv'><![CDATA[\(inputTextView.string)]]></input>
            <output format='json'><![CDATA[\(outputTextView.string)]]></output>
            <prompt llm='TestLlama v0'><![CDATA[\(promptTextView.string)]]></prompt>
            <script language='Python 3.13'><![CDATA[\(scriptTextView.string)]]></script>
        </mutabit>
        """
        guard let data = xml.data(using: .utf8) else {
            fatalError("Unable to convert document to UTF-8")
        }
        return data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let xml = MbitXML(data: data) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        DispatchQueue.main.async {
            self.isNewDocument = false
            self.inputTextView.string = xml.input
            self.outputTextView.string = xml.output
            self.promptTextView.string = xml.prompt
            self.scriptTextView.string = xml.script
        }
    }
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        super.windowControllerDidLoadNib(windowController)
        
        configureTextView(inputTextView)
        configureTextView(outputTextView)
        configureTextView(promptTextView)
        configureTextView(scriptTextView)

        if isNewDocument {
            scriptTextView.string = appDelegate.script.code
        }
    }}
