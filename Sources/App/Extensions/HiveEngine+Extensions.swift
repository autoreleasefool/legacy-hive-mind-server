//
//  HiveEngine+Extensions.swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//

import Vapor
import HiveEngine

extension GameState {
	func json() -> String {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(self) else { return "" }
		return String(data: data, encoding: .utf8)!
	}
}

extension GameState: Content { }

extension Movement: Content { }
