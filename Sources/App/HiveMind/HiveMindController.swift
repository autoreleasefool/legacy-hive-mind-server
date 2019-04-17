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
	func new(_ request: Request) throws -> Future<HTTPStatus> {
		return try request.content.decode(Initialization.self).flatMap { [weak self] initialization in
			return HiveMind.start(initialization: initialization, on: request.eventLoop).map { hiveMind in
				self?.hiveMind = hiveMind
				return HTTPStatus.ok
			}
		}
	}

	/// Requests the HiveMind for a move and plays it
	func play(_ request: Request) throws -> Future<Movement> {
		guard let hiveMind = self.hiveMind else { throw HiveMindError.notInitialized }
		return try request.content.decode(Movement.self).flatMap({ movement in
			return hiveMind.apply(movement: movement, on: request.eventLoop).flatMap {
				return hiveMind.play(on: request.eventLoop).map { response in
					return response
				}
			}
		})
	}

	/// Close the current HiveMindProcess
	func close(_ request: Request) throws -> Future<HTTPStatus> {
		self.hiveMind = nil
		return request.eventLoop.newSucceededFuture(result: .ok)
	}
}
