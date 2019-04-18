//
//  HiveEngine+Extensions.swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Vapor
import HiveEngine

extension GameState {
	func json() -> String {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(self) else { return "" }
		return String(data: data, encoding: .utf8) ?? ""
	}
}

extension Movement {
	func json() -> String {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(self) else { return "" }
		return String(data: data, encoding: .utf8) ?? ""
	}

	static func decode(_ string: String) -> Movement? {
		let decoder = JSONDecoder()
		guard let data = string.data(using: .utf8), let movement = try? decoder.decode(Movement.self, from: data) else {
			return nil
		}

		return movement
	}
}

extension Movement: Content { }
