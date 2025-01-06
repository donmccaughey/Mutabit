import Cocoa


class MbitDocument: NSDocument {
    @IBOutlet weak var outputTextView: NSTextView!
    @IBOutlet weak var promptTextView: NSTextView!
    @IBOutlet weak var scriptTextView: NSTextView!
    @IBOutlet weak var sourceTextView: NSTextView!
    
    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("MbitDocument")
    }

    override func data(ofType typeName: String) throws -> Data {
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

}
