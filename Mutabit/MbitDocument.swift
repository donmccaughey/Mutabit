import Cocoa


class MbitDocument: NSDocument {
    @IBOutlet weak var inputTextView: NSTextView!
    @IBOutlet weak var outputTextView: NSTextView!
    @IBOutlet weak var promptTextView: NSTextView!
    @IBOutlet weak var scriptTextView: NSTextView!
    
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
            self.inputTextView.string = xml.input
            self.outputTextView.string = xml.output
            self.promptTextView.string = xml.prompt
            self.scriptTextView.string = xml.script
        }
    }
}
