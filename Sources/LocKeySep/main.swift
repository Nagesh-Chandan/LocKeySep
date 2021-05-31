
import ArgumentParser
import Foundation


enum FileTypes: String {
    case strings
}

let supportedFileTypes: [FileTypes] = [.strings]


var isVerbose: Bool = true

func verboseLog(_ text: String?) {
    guard isVerbose else { return }
    log(text)
}


func log(_ text: String?) {
    guard let log = text else { return debugPrint("[skiped log]") }
    print(log)
}


struct lockeysep: ParsableCommand {
    public static let configuration = CommandConfiguration(
        abstract: "A Swift command-line to extract keys from a .strings file",
        subcommands: [])
    
    @Option(name: .shortAndLong, help: "Path to .strings file")
    private var filePath: String

    @Flag(name: .long, help: "This is verbose")
    private var verbose: Bool = false
    
    init() {}
    
    func run() {
        isVerbose = self.verbose
        log("Reading file at \(filePath)")
        let fileParser = FileOptionParser(filePath: filePath)
        guard fileParser.isExists() else {
            return log("No such file \(filePath)")
        }
        guard fileParser.isStringsFile() else {
            return log("\(filePath) is not a .strings file")
        }
        
        let result = fileParser.allLines()
        switch result {
        case .success(let lines):
            let keys = fileParser.process(lines: lines)
            log("======= Start =======")
            keys.forEach { (key) in
                log(key)
            }
            log("======== End ========")
        case .failure(let error):
            log(error.localizedDescription)
        }
    }

}

lockeysep.main()


protocol FileOptionParsable {
    func isStringsFile() -> Bool
}

struct FileOptionParser: FileOptionParsable {
    let filePath: String
    
    let fileManager = FileManager.default
    
    
    init(filePath: String) {
        self.filePath = filePath
    }
    
    func isExists() -> Bool {
       return fileManager.fileExists(atPath: filePath)
    }
    
    func isStringsFile() -> Bool {
        guard let filePath = URL(string: self.filePath) else {
            return false
        }
        guard let pathType = FileTypes.init(rawValue: filePath.pathExtension),
           supportedFileTypes.contains(pathType) else {
            return false
        }
        return true
    }
    
    func allLines() -> Result<[String], Error> {
        do {
            let data = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = data.components(separatedBy: .newlines)
            return .success(lines)
        }catch let error {
            return .failure(error)
        }
       
    }
    
    func process(lines: [String]) -> [String] {
        var output:[String] = []
        lines.forEach { line in
            if !line.isEmpty {
                verboseLog("processing line \(line)")
                if let key = extractKey(from: line) {
                    verboseLog("Found key `\(key)` in line \(line)")
                    let trimmedKey = key.replacingOccurrences(of: "\"", with: "")
                    output.append(trimmedKey)
                }else {
                    verboseLog("key not found in line \(line)")
                }
            }else {
                verboseLog("Read empty line\(line)")
            }
        }
        return output
    }
    
    func extractKey(from line: String) -> String? {
        verboseLog("extracting key \(line)")
        guard line.contains("="),
              let key =  line.split(separator: "=").first else {
            return nil
        }
        return String(key)
    }    
}




