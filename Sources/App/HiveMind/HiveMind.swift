//
//  HiveMind .swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine
import WebSocket

class HiveMind {
	struct Configuration {
		/// Indicates if the HiveMind will play first (true) or second (false) in the game
		let isFirst: Bool
		/// Amount of time the HiveMind will be allowed to explore before a move is requested
		let explorationTime: TimeInterval = 10
		/// Hostname for the connection to the HiveMind
		let hostname: String = "localhost"
		/// Port number for the connection to the HiveMind
		let port: Int = 8081
	}

	/// Socket connection to the HiveMind
	private let socket: WebSocket

	/// Worker that server events will be handled with.
	private let group: EventLoopGroup

	/// Configuration of the HiveMind connection
	private let configuration: Configuration

	/// Callback for the next `Movement` returned from the HiveMind
	private var onNextMovement: ((SocketResponse, Error?) -> Void)?

	/// Callback for the next response from the HiveMind after sending a `Movement`
	private var onMovementResponse: ((SocketResponse) -> Void)?

	init(configuration: Configuration = Configuration(isFirst: true)) throws {
		self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
		self.configuration = configuration
		socket = try HTTPClient.webSocket(
			scheme: .ws,
			hostname: configuration.hostname,
			port: configuration.port,
			on: group
		).wait()

		socket.onText { [weak self] _, text in
			self?.handle(response: SocketResponse.from(string: text))
		}

		send(.new(configuration.isFirst, configuration.explorationTime))
	}

	/// Create an instance of `HiveMind` and return the result as a `Future` on the given `EventLoop`
	///
	/// - Parameters:
	///   - initialization: AI Initialization parameters
	///   - eventLoop: the EventLoop to process the request with
	static func start(initialization: Initialization, on eventLoop: EventLoop) -> Future<HiveMind> {
		let promise = eventLoop.newPromise(of: HiveMind.self)
		DispatchQueue.global().async {
			do {
				let hiveMind = try HiveMind(configuration: Configuration(isFirst: !initialization.playerIsFirst))
				promise.succeed(result: hiveMind)
			} catch {
				promise.fail(error: error)
			}
		}
		return promise.futureResult
	}

	deinit {
		close()
	}

	/// Ask for a `Movement` from the HiveMind.
	///
	/// - Parameters:
	///   - eventLoop: the EventLoop to process the request with
	func play(on eventLoop: EventLoop) -> Future<Movement> {
		let promise = eventLoop.newPromise(of: Movement.self)

		self.onNextMovement?(.failure, nil)
		self.onNextMovement = { response, error in
			switch response {
			case .failure, .invalidCommand:
				if let error = error {
					promise.fail(error: error)
				} else {
					promise.fail(error: HiveMindError.noMovement)
				}
			case .success:
				promise.fail(error: HiveMindError.timing)
			case .movement(let movement):
				promise.succeed(result: movement)
			}
		}

		print("Asking HiveMind for movement...")
		send(.play)

		let explorationTime = configuration.explorationTime + 2
		DispatchQueue.global().asyncAfter(deadline: .now() + explorationTime) { [weak self] in
			guard let self = self else { return }
			self.onNextMovement?(.failure, HiveMindError.timeOut)
			self.onNextMovement = nil
		}

		return promise.futureResult
	}

	/// Forward a `Movement` to the HiveMind.
	///
	/// - Parameters:
	///   - movement: the movement to apply, which should be valid in the HiveMind's current state.
	///   - eventLoop: `EventLoop` to return a Promise with when the HiveMind accepts the `Movement`
	func apply(movement: Movement, on eventLoop: EventLoop) -> Future<Void> {
		let promise = eventLoop.newPromise(of: Void.self)
		self.onMovementResponse = { response in
			switch response {
			case .failure, .invalidCommand:
				promise.fail(error: HiveMindError.movementRejected)
			case .movement:
				promise.fail(error: HiveMindError.timing)
			case .success:
				promise.succeed()
			}
		}

		print("Applying movement `\(movement)")
		send(.movement(movement))

		return promise.futureResult
	}

	/// Close the current HiveMind process.
	func close() {
		if socket.isClosed == false {
			send(.quitGame)
			socket.close(code: .goingAway)
			print("Began HiveMind socket termination")
		}

		group.shutdownGracefully { _ in }
	}

	/// Write a message to the Socket for the HiveMind to received.
	///
	/// - Parameters:
	///   - message: the message to send
	private func send(_ message: SocketMessage) {
		socket.send(message.description)
	}

	/// Handle a `SocketResponse` from the Socket and update the server appropriately.
	///
	/// - Parameters:
	///   - response: a message from the WebSocket
	private func handle(response: SocketResponse) {
		self.onNextMovement?(response, nil)
		self.onNextMovement = nil

		self.onMovementResponse?(response)
		self.onMovementResponse = nil
	}
}

enum SocketMessage: CustomStringConvertible {
	case new(Bool, Double)
	case play
	case movement(Movement)
	case quitGame

	public var description: String {
		switch self {
		case .new(let isFirst, let explorationTime):
			return "new \(isFirst) \(explorationTime)"
		case .play:
			return "play"
		case .movement(let movement):
			return "move \(movement.json())"
		case .quitGame:
			return "quit"
		}
	}
}

enum SocketResponse {
	case success
	case movement(Movement)
	case failure
	case invalidCommand

	static func from(string: String) -> SocketResponse {
		switch string {
		case "SUCCESS": return .success
		case "FAILED": return .failure
		default:
			if let movement = Movement.decode(string) {
				return .movement(movement)
			}
			return .invalidCommand
		}
	}
}
