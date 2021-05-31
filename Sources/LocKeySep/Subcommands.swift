//
//  Created by Nagesh Chandan on 31/05/21.
//

import Foundation
import ArgumentParser





struct Generate: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "CLI for extracting the keys from a .strings file")

    @Argument(help: "The title of the blog post")
    private var title: String

    @Option(name: .shortAndLong, help: "Path to .strings file")
    private var inputFilePath: String?

    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool = false
    
    
    func run() throws {
        isVerbose = self.verbose
        verboseLog("Reading file at \(String(describing: inputFilePath))")
    }
}




