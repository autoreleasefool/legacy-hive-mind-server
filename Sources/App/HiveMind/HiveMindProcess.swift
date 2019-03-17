//
//  HiveMindProcess.swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//

import Foundation
import HiveEngine

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

	var currentState: GameState?
	var hiveMindPlayer: Player = .white

	func play() -> Movement {
		guard let state = currentState else { fatalError("GameState was not initialized") }
		let executable = self.executable
		print(executable)

		let (output, _) = shell(executable.absoluteString, ["'\(state.json())'"])
		let decoder = JSONDecoder()
		if let output = output, let data = output.data(using: .utf8), let movement = try? decoder.decode(Movement.self, from: data) {
			return movement
		} else {
			fatalError("failed to decode movement")
		}
	}
}
