//
//  HiveMind .swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//

import Foundation
import HiveEngine
import Starscream
import Core

enum SocketMessage: CustomStringConvertible {
	case new(Bool, Double)
	case play
	case move(Movement)

	public var description: String {
		switch self {
		case .new(let isFirst, let explorationTime):
			return "new \(isFirst) \(explorationTime)"
		case .play:
			return "play"
		case .move(let movement):
			return "move \(movement.json())"
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

class HiveMind {

	/// Default time to allow the HiveMind to explore
	private static let explorationTime: TimeInterval = 10

	/// Socket connection to the HiveMind
	private let socket: Starscream.WebSocket

	/// If true, the HiveMind will play first in the game, and if false, it will play second.
	private let isFirst: Bool

	/// Identifier for the current promise to be fulfilled
	private var movementPromiseID: Int = 0
	/// The most recent promise waiting for a Movement.
	private var nextMovementPromise: EventLoopPromise<Movement>? = nil

	init?(isFirst: Bool) {
		guard let url = URL(string: "ws://localhost:8081") else { return nil }
		self.isFirst = isFirst
		socket = WebSocket(url: url)
		socket.delegate = self
		socket.connect()
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

		writeToSocket(message: .play)

		let explorationTime = HiveMind.explorationTime + 2
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
	///   - move: the movement to apply, which should be valid in the HiveMind's current state.
	///           If the movement is not valid, the HiveMind will fail silently.
	func apply(move: Movement) {
		print("Applying movement `\(move)")
		writeToSocket(message: .move(move))
	}

	/// Close the current HiveMind process.
	func close() {
		if socket.isConnected {
			socket.disconnect()
			print("Began HiveMind socket termination")
		}
	}

	/// Write a message to the Socket for the HiveMind to received.
	private func writeToSocket(message: SocketMessage) {
		socket.write(string: message.description)
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

extension HiveMind: WebSocketDelegate {
	public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
		print("WebSocket received some Data: \(data.count) elements.")
		if let input = String(data: data, encoding: .utf8) {
			let response = SocketResponse.from(string: input)
			handle(response: response)
		} else {
			print("Failed to decode Data as String.")
		}
	}

	public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		print("WebSocket recieved some Text: \(text.count) characters.")
		let response = SocketResponse.from(string: text)
		handle(response: response)
	}

	func websocketDidConnect(socket: WebSocketClient) {
		print("Connected to HiveMind socket.")

	}

	func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		print("Disconnected from HiveMind socket.")
	}
}
