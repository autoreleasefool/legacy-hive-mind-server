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
	case stringToDataConversion(String)
	case dataToStringConversion
	case JSONExtraction(String)
}

/// Additional error details
extension HiveMindError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .notInitialized: return "An instance of the HiveMind has not been initialized"
		case .stringToDataConversion(let string): return "Failed to convert `\(string)` to Data"
		case .JSONExtraction(let string): return "Could not extract JSON from string `\(string)`"
		case .dataToStringConversion: return "Failed to convert Data to String"
		}
	}
}
