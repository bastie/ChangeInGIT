/*
 * SPDX-FileCopyrightText: 2022 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation

if #available(macOS 10.13, *) { // build on macOS need this, on raspberry not needed

    struct ci_git {
        let ONE_MINUTE : UInt32 = 60_000_000

        let stopFile = "./CIstop"
        let workFile = "./CIdoIt.exe"
        let defaultWorkFileContent =
            """
            #!/bin/bash
            
            echo "CI task not implemented"
            echo "Insert content on *ix systems or replace this file on Win* systems"
            
            ### EOF
            """

        var lastGitHash = ""
        var checkItAgain : Bool?
        
        func checkOrCreateWorkFile () throws {
            if false == FileManager.default.fileExists(atPath: workFile) {
                FileManager.default.createFile(atPath: workFile, contents: defaultWorkFileContent.data(using: .utf8), attributes: nil)
                var chmod : Process?
                if FileManager.default.fileExists(atPath: "/usr/bin/chmod") {
                    chmod = Process()
                    chmod!.executableURL = URL(fileURLWithPath:  "/usr/bin/chmod") //raspberry pi linux
                }
                else {
                    if FileManager.default.fileExists(atPath: "/bin/chmod") {
                        chmod = Process()
                        chmod!.executableURL = URL(fileURLWithPath:  "/bin/chmod") // macOS
                    }
                }
                if let process = chmod {
                    process.arguments = ["+x", workFile]
                    try process.run()
                }
            }
        }

        mutating func doIt () throws {
            repeat {
                if let _ = checkItAgain {
                    usleep(ONE_MINUTE)
                }
                let outputPipe = Pipe()
                let errorPipe = Pipe()

                let checkTask = Process()
                checkTask.executableURL = URL (fileURLWithPath: "/usr/bin/git")
                checkTask.standardOutput = outputPipe
                checkTask.standardError = errorPipe

                let myProject = "." // from repo: "https://github.com/bastie/broiler.git"
                checkTask.arguments = ["ls-remote", myProject, "refs/heads/main"]



                try checkTask.run()
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(decoding: outputData, as: UTF8.self)
                let _ = String(decoding: errorData, as: UTF8.self)

                let gitHash = output.components(separatedBy: .whitespacesAndNewlines)[0]
                switch gitHash {
                case lastGitHash: break
                default:
                    let doTask = Process()
                    doTask.executableURL = URL (fileURLWithPath: workFile)
                    try doTask.run()
                    lastGitHash = gitHash
                }
                
                if FileManager.default.fileExists(atPath: stopFile) {
                    checkItAgain = false
                }
                else {
                    checkItAgain = true
                }
                
            }
            while (checkItAgain!)

            try FileManager.default.removeItem(atPath: stopFile)
        }
    }

    var doIt = ci_git()
    try doIt.checkOrCreateWorkFile()
    try doIt.doIt()
} else {
    
}
