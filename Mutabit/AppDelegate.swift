import Cocoa


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let script: Script
    let textAttributes: [NSAttributedString.Key: Any]

    override init() {
        self.script = Script()
        textAttributes = [
            .backgroundColor: NSColor.textBackgroundColor,
            .font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular),
            .foregroundColor: NSColor.textColor,
        ]
        super.init()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}
