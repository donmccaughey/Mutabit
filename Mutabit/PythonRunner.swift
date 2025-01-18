import Foundation


let PythonRunnerWillStartRunningNotification = Notification.Name("PythonRunnerWillStartRunning")
let PythonRunnerDidFinishRunningNotification = Notification.Name("PythonRunnerDidFinishRunning")
let PythonRunnerErrorKey = "PythonRunnerError"


class PythonRunner: @unchecked Sendable {
    enum PythonRunnerError: Error {
        case pythonNotFound
        case scriptExecutionFailed(String)
        case outputReadError
        case processTerminated
    }
    
    private let pythonPath: String
    private let input: String
    private let script: String
    public private(set) var output: String?
    public private(set) var error: String?
    
    init(input: String, script: String, pythonPath: String = "/usr/bin/python3") {
        self.input = input
        self.script = script
        self.pythonPath = pythonPath
    }
    
    func startRunning() {
        NotificationCenter.default.post(name: PythonRunnerWillStartRunningNotification, object: self)
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard FileManager.default.fileExists(atPath: self.pythonPath) else {
                DispatchQueue.main.async {
                    let userInfo = [PythonRunnerErrorKey: PythonRunnerError.pythonNotFound]
                    NotificationCenter.default.post(name: PythonRunnerDidFinishRunningNotification, object: self, userInfo: userInfo)
                }
                return
            }
            print("Python exists at '\(self.pythonPath)'")
            
            let tempDirectory = FileManager.default.temporaryDirectory
            let scriptURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".py")
            do {
                try self.script.write(to: scriptURL, atomically: true, encoding: .utf8)
            } catch {
                DispatchQueue.main.async {
                    let userInfo = [PythonRunnerErrorKey: error]
                    NotificationCenter.default.post(name: PythonRunnerDidFinishRunningNotification, object: self, userInfo: userInfo)
                }
                return
            }
            print("Wrote script to '\(scriptURL.path)'")
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.pythonPath)
            process.arguments = [scriptURL.path]
            
            let stdinPipe = Pipe()
            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            
            process.standardInput = stdinPipe
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
            process.terminationHandler = { process in
                try? FileManager.default.removeItem(at: scriptURL)
                
                let outputData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                guard let output = String(data: outputData, encoding: .utf8),
                      let error = String(data: errorData, encoding: .utf8)
                else {
                    DispatchQueue.main.async {
                        let userInfo = [PythonRunnerErrorKey: PythonRunnerError.outputReadError]
                        NotificationCenter.default.post(name: PythonRunnerDidFinishRunningNotification, object: self, userInfo: userInfo)
                    }
                    return
                }
                
                if process.terminationStatus != 0 {
                    print("Error \(process.terminationStatus):\n\n\(error)\n\n")
                    DispatchQueue.main.async {
                        let userInfo = [PythonRunnerErrorKey: PythonRunnerError.scriptExecutionFailed("Process terminated with status \(process.terminationStatus)")]
                        NotificationCenter.default.post(name: PythonRunnerDidFinishRunningNotification, object: self, userInfo: userInfo)
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.output = output
                    self.error = error
                    NotificationCenter.default.post(name: PythonRunnerDidFinishRunningNotification, object: self)
                }
            }
            
            do {
                if !self.input.isEmpty {
                    guard let inputData = self.input.data(using: .utf8) else {
                        fatalError("Unable to encode input text as UTF-8")
                    }
                    try stdinPipe.fileHandleForWriting.write(contentsOf: inputData)
                }
                try stdinPipe.fileHandleForWriting.close()
                try process.run()
            } catch {
                DispatchQueue.main.async {
                    let userInfo = [PythonRunnerErrorKey: error]
                    NotificationCenter.default.post(name: PythonRunnerDidFinishRunningNotification, object: self, userInfo: userInfo)
                }
                try? FileManager.default.removeItem(at: scriptURL)
                return
            }

        }
    }
}
