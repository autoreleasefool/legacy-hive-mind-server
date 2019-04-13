//
//  HiveMindController.swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//

import Vapor
import HiveEngine

final class HiveMindController {

	/// Connection to the HiveMind
	private var hiveMind: HiveMind?

	/// Creates a new instance of the HiveMind and begins a game
	func new(_ req: Request) throws -> Future<HTTPStatus> {
		return try req.content.decode(Initialization.self).map(to: HTTPStatus.self) { [weak self] initialization in
			self?.hiveMind = HiveMind(isFirst: !initialization.playerIsFirst)
			return .ok
		}
	}

	/// Requests the HiveMind for a move and plays it
	func play(_ req: Request) throws -> Future<Movement> {
		guard let hiveMind = self.hiveMind else { throw HiveMindError.notInitialized }
		return try req.content.decode(Movement.self)
			.flatMap({ move in
				hiveMind.apply(move: move)
				return hiveMind.play(on: req.eventLoop).map { response in
					return response
				}
			})
	}

	/// Close the current HiveMindProcess
	func close(_ req: Request) throws -> Future<HTTPStatus> {
		self.hiveMind = nil
		return req.eventLoop.newSucceededFuture(result: .ok)
	}
}
