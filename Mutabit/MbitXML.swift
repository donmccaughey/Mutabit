import Foundation


class MbitXML: NSObject, XMLParserDelegate {
    var input: String = ""
    var output: String = ""
    var prompt: String = ""
    var script: String = ""
    
    private var currentElement: String = ""
    private var currentText: String = ""
    
    init?(data: Data) {
        super.init()
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        if !parser.parse() {
            return nil
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentText = ""
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            currentText = string
            
            // Store the text in the appropriate property
            switch currentElement {
            case "input":
                input = string
            case "output":
                output = string
            case "prompt":
                prompt = string
            case "script":
                script = string
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parsing error: \(parseError.localizedDescription)")
    }
}
