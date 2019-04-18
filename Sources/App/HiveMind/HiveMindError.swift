//
//  HiveMindError.swift
//  App
//
//  Created by Joseph Roque on 2019-04-07.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

/// Common errors from interacting with the HiveMind process
enum HiveMindError: Error {
	case notInitialized
	case noMovement
	case timeOut
	case movementRejected
	case timing
}

/// Additional error details
extension HiveMindError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .notInitialized: return "An instance of the HiveMind has not been initialized"
		case .noMovement: return "HiveMind returned no movement."
		case .timeOut: return "HiveMind timed out waiting for a response."
		case .movementRejected: return "The Movement passed to HiveMind was not valid"
		case .timing: return "Either HiveMind or the server has encountered an unexpected timing issue"
		}
	}
}
