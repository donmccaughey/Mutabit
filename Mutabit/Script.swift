import Foundation


class Script {
    let code: String
    
    init() {
        guard let url = Bundle.main.url(forResource: "convert", withExtension: "py") else {
            fatalError("Unable to load 'convert.py' from app bundle")
        }
        guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("Unable to encode 'convert.py' to UTF-8")
        }
        code = contents
    }
}
