//
//  HiveMindProcess.swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//

import Foundation
import HiveEngine
import Vapor

enum HiveMindError: Error {
	case notInitialized
	case invalidOutput
	case invalidMovement
	case unknown
}

class HiveMindProcess {

	/// Location of the HiveMind executable
	private var executable: URL {
		return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
			.appendingPathComponent("..")
			.appendingPathComponent("hive-engine")
			.appendingPathComponent(".build")
			.appendingPathComponent("release")
			.appendingPathComponent("HiveMind")
	}

	private let process = Process()

	init(isFirst: Bool) throws {
		process.executableURL = executable
		try process.run()

		process.standardInput = "--new \(isFirst)\n"
	}

	/// Ask for a `Movement` from the HiveMind.
	///
	/// - Parameters:
	///   - req: the server request made
	func play(req: Request) -> Future<Movement> {
		process.standardInput = "--play\n"
		let movementPromise = req.eventLoop.newPromise(of: Movement.self)

		// TODO: 12 seconds should be a configuration for the HiveMind, rather than a constant in each project
		DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
			guard let self = self else {
				print("`self` was nil after waiting for move")
				movementPromise.fail(error: HiveMindError.unknown)
				return
			}

			guard let rawOutput = self.process.standardOutput as? String else {
				print("STDOUT `\(String(describing: self.process.standardOutput))` was not a valid String")
				movementPromise.fail(error: HiveMindError.invalidOutput)
				return
			}

			let decoder = JSONDecoder()
			guard let data = rawOutput.data(using: .utf8), let move = try? decoder.decode(Movement.self, from: data) else {
				print("Could not decode Movement from `\(rawOutput)`")
				movementPromise.fail(error: HiveMindError.invalidMovement)
				return
			}

			movementPromise.succeed(result: move)
		}

		return movementPromise.futureResult
	}

	/// Forward a `Movement` to the HiveMind.
	///
	/// - Parameters:
	///   - move: the movement to apply, which should be valid in the HiveMind's current state. If the movement is not valid,
	///           the HiveMind process will fail silently.
	func apply(move: Movement) {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(move), let moveString = String(data: data, encoding: .utf8) else {
			print("Failed to pass move `\(move)` to HiveMind")
			return
		}

		process.standardInput = "--move \"\(moveString)\"\n"
	}
}
