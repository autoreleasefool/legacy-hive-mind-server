//
//  HiveMindError.swift
//  App
//
//  Created by Joseph Roque on 2019-04-07.
//

import Foundation

/// Common errors from interacting with the HiveMind process
enum HiveMindError: Error {
	case notInitialized
	case noMovement
	case timeOut
}

/// Additional error details
extension HiveMindError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .notInitialized: return "An instance of the HiveMind has not been initialized"
		case .noMovement: return "HiveMind returned no movement."
		case .timeOut: return "HiveMind timed out waiting for a response."
		}
	}
}
