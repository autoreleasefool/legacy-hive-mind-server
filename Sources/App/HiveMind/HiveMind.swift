//
//  HiveMind .swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
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

	/// Identifier for the current promise to be fulfilled
	private var movementPromiseID: Int = 0
	/// The most recent promise waiting for a Movement.
	private var nextMovementPromise: EventLoopPromise<Movement>? = nil

	init(configuration: Configuration = Configuration(isFirst: true)) throws {
		self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
		self.configuration = configuration
		socket = try HTTPClient.webSocket(
			scheme: .ws,
			hostname: configuration.hostname,
			port: configuration.port,
			on: group
		).wait()

		socket.onText { [weak self] ws, text in
			self?.handle(response: SocketResponse.from(string: text))
		}

		send(.new(configuration.isFirst, configuration.explorationTime))
	}

	/// Create an instance of `HiveMind` and return the result as a `Future` on the given `EventLoop`
	static func start(initialization: Initialization, eventLoop: EventLoop) -> Future<HiveMind> {
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
		print("Asking HiveMind for movement...")
		let movementPromise = eventLoop.newPromise(of: Movement.self)

		// Update the current promise waiting for a response
		if let previousMovementPromise = nextMovementPromise {
			previousMovementPromise.fail(error: HiveMindError.noMovement)
		}

		let nextID = movementPromiseID + 1
		movementPromiseID = nextID
		nextMovementPromise = movementPromise

		send(.play)

		let explorationTime = configuration.explorationTime + 2
		DispatchQueue.global().asyncAfter(deadline: .now() + explorationTime) { [weak self] in
			guard let self = self else { return }
			guard let currentMovementPromise = self.nextMovementPromise, nextID == self.movementPromiseID else { return }
			currentMovementPromise.fail(error: HiveMindError.timeOut)
			self.nextMovementPromise = nil
		}

		return movementPromise.futureResult
	}

	/// Forward a `Movement` to the HiveMind.
	///
	/// - Parameters:
	///   - movement: the movement to apply, which should be valid in the HiveMind's current state.
	///               If the movement is not valid, the HiveMind will fail silently.
	func apply(movement: Movement) {
		print("Applying movement `\(movement)")
		send(.movement(movement))
	}

	/// Close the current HiveMind process.
	func close() {
		if socket.isClosed == false {
			send(.exit)
			socket.close()
			print("Began HiveMind socket termination")
		}

		group.shutdownGracefully { _ in }
	}

	/// Write a message to the Socket for the HiveMind to received.
	private func send(_ message: SocketMessage) {
		socket.send(message.description)
	}

	/// Handle a `SocketResponse` from the Socket and update the server appropriately.
	private func handle(response: SocketResponse) {
		switch response {
		case .failure, .invalidCommand:
			if let movementPromise = nextMovementPromise {
				movementPromise.fail(error: HiveMindError.noMovement)
				nextMovementPromise = nil
			}
		case .movement(let movement):
			if let movementPromise = nextMovementPromise {
				movementPromise.succeed(result: movement)
				nextMovementPromise = nil
			}
		case .success:
			// Does nothing
			break
		}
	}
}

enum SocketMessage: CustomStringConvertible {
	case new(Bool, Double)
	case play
	case movement(Movement)
	case exit

	public var description: String {
		switch self {
		case .new(let isFirst, let explorationTime):
			return "new \(isFirst) \(explorationTime)"
		case .play:
			return "play"
		case .movement(let movement):
			return "move \(movement.json())"
		case .exit:
			return "exit"
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
