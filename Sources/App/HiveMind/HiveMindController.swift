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
	private var hiveMindProcess: HiveMindProcess?

	/// Creates a new instance of the HiveMind and begins a game
	func new(_ req: Request) throws -> Future<HTTPStatus> {
		return try req.content.decode(Initialization.self).map(to: HTTPStatus.self) { [weak self] initialization in
			do {
				self?.hiveMindProcess = try HiveMindProcess(isFirst: !initialization.playerIsFirst)
			} catch {
				print("An error occurred while starting the HiveMindProcess: \(error)")
				return .internalServerError
			}

			return .ok
		}
	}

	/// Requests the HiveMind for a move and plays it
	func play(_ req: Request) throws -> Future<Movement> {
		guard let hiveMindProcess = self.hiveMindProcess else { throw HiveMindError.notInitialized }
		return try req.content.decode(Movement.self)
			.flatMap({ move in
				hiveMindProcess.apply(move: move)
				return hiveMindProcess.play(req: req).map { response in
					return response
				}
			})
	}

	/// Close the current HiveMindProcess
	func close(_ req: Request) throws -> Future<HTTPStatus> {
		let result = req.eventLoop.newPromise(of: HTTPStatus.self)

		self.hiveMindProcess = nil
		result.succeed(result: .ok)

		return result.futureResult
	}
}
