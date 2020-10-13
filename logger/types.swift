//
//  types.swift
//  Test
//
//  Created by Daniel Brain on 10/12/20.
//

import Foundation

typealias Payload = [String: String]
typealias Headers = [String: String]

enum LogLevel: String {
    case debug, info, warn, error
}

struct Event: Codable {
    let level: LogLevel.RawValue
    let name: String
    let payload: Payload
}

struct Events: Codable {
    var events: [Event] = []
    var tracking: [Payload] = []
}
