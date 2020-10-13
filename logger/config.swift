//
//  config.swift
//  Test
//
//  Created by Daniel Brain on 10/12/20.
//

import Foundation

// Time to wait/debounce after flush() calls
let FLUSH_DEBOUNCE_TIME = 0.5

// Default log level to print in console
let DEFAULT_LOGLEVEL: LogLevel = .info

// Default interval after which to auto-flush logs
let DEFAULT_FLUSH_INTERVAL: Double = 60.0

// Maximum number of logs to keep in buffer between flushes
let MAX_BUFFERED_LOGS = 50

// Log level priority
let LOG_LEVEL_PRIORITY = [
    LogLevel.error,
    LogLevel.warn,
    LogLevel.info,
    LogLevel.debug
]
