//
//  routes.swift
//  App
//
//  Created by Joseph Roque on 2019-03-17.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Vapor
import HiveEngine

public func routes(_ router: Router) throws {
	let hiveMindController = HiveMindController()
	router.post("new", use: hiveMindController.new)
	router.post("play", use: hiveMindController.play)
	router.post("close", use: hiveMindController.close)
}

struct Initialization: Content {
	let playerIsFirst: Bool
}
