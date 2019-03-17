//
//  HiveMindController.swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//

import Vapor
import HiveEngine

final class HiveMindController {

	let hiveMindProcess = HiveMindProcess()

	/// Creates a new instance of the HiveMind and begins a game.
	func new(_ req: Request) throws -> Future<HTTPStatus> {
		return try req.content.decode(Initialization.self).map(to: HTTPStatus.self) { [weak self] initialization in
			self?.hiveMindProcess.hiveMindPlayer = initialization.playerIsFirst ? .black : .white
			return .ok
		}
	}

	/// Requests the HiveMind for a move and plays it
	func play(_ req: Request) throws -> Future<Movement> {
		return try req.content.decode(GameState.self).map(to: Movement.self) { [weak self] state in
			self!.hiveMindProcess.currentState = state
			return self!.hiveMindProcess.play()
		}
	}
}
