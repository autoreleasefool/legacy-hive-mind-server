//
//  Shell.swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//

import Foundation

// wrapper function for shell commands
// must provide full path to executable
func shell(_ launchPath: String, _ arguments: [String] = []) -> (String?, Int32) {
	let task = Process()
	task.executableURL = URL(fileURLWithPath: launchPath)
	task.arguments = arguments

	let pipe = Pipe()
	task.standardOutput = pipe
	task.standardError = pipe

	do {
		try task.run()
	} catch {
		// handle errors
		print("Error: \(error.localizedDescription)")
	}

	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = String(data: data, encoding: .utf8)

	task.waitUntilExit()
	return (output, task.terminationStatus)
}
