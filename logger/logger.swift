//
//  logger.swift
//  Test
//
//  Created by Daniel Brain on 10/11/20.
//

import Foundation

let DEFAULT_PAYLOAD: Payload = [:]

class Logger {
    private let url: URL
    private let prefix: String?
    private let logLevel: LogLevel
    private let flushInterval: Double
    
    private var events = Events()
    private var headerBuilders: [() -> Headers] = []
    private var payloadBuilders: [() -> Payload] = []
    private var trackingBuilders: [() -> Payload] = []
    
    init(
        url : String,
        prefix : String? = nil,
        logLevel : LogLevel = DEFAULT_LOGLEVEL,
        flushInterval: Double = DEFAULT_FLUSH_INTERVAL
    ) {
        if (flushInterval <= (FLUSH_DEBOUNCE_TIME * 2)) {
            preconditionFailure("flushInterval must be greater than \( (FLUSH_DEBOUNCE_TIME * 2) )")
        }
        
        self.url = URL(string: url)!
        self.prefix = prefix
        self.logLevel = logLevel
        self.flushInterval = flushInterval
        
        setupFlushInterval()
    }
    
    private func output(level: LogLevel, name: String, payload: Payload = DEFAULT_PAYLOAD) {
        let currentLogLevel = LOG_LEVEL_PRIORITY.firstIndex(of: level)!
        let allowedLogLevel = LOG_LEVEL_PRIORITY.firstIndex(of: logLevel)!
        
        if (currentLogLevel <= allowedLogLevel) {
            print(level, name, payload)
        }
    }
    
    private func log(level: LogLevel, name: String, payload: Payload = DEFAULT_PAYLOAD) -> Logger {
        output(level: level, name: name, payload: payload)
        
        if (events.events.count >= MAX_BUFFERED_LOGS) {
            return self
        }
        
        var eventPayload = payload
        
        payloadBuilders.forEach { builder in
            eventPayload.merge(builder()) { (first, second) in
                second
            }
        }
        
        events.events.append(Event(
            level: level.rawValue,
            name: name,
            payload: eventPayload
        ))
        
        return self
    }
    
    @discardableResult public func debug(name: String, payload: Payload = DEFAULT_PAYLOAD) -> Logger {
        log(level: .debug, name: name, payload: payload)
    }
    
    @discardableResult public func info(name: String, payload: Payload = DEFAULT_PAYLOAD) -> Logger {
        log(level: .info, name: name, payload: payload)
    }
    
    @discardableResult public func warn(name: String, payload: Payload = DEFAULT_PAYLOAD) -> Logger {
        log(level: .warn, name: name, payload: payload)
    }
    
    @discardableResult public func error(name: String, payload: Payload = DEFAULT_PAYLOAD) -> Logger {
        log(level: .error, name: name, payload: payload)
    }
    
    @discardableResult public func track(payload: Payload) -> Logger {
        output(level: .info, name: "track", payload: payload)
        
        if (events.tracking.count >= MAX_BUFFERED_LOGS) {
            return self
        }
        
        var trackingPayload = payload
        
        trackingBuilders.forEach { builder in
            trackingPayload.merge(builder()) { (first, second) in
                second
            }
        }
        
        events.tracking.append(trackingPayload)
        return self
    }
    
    @discardableResult public func flush(callback: @escaping EmptyCallback = noopEmptyCallback) -> Logger {
        self.flush() { (_: Result<Void, Error>) in
            callback()
        }
    }
    
    @discardableResult public func flush(callback: @escaping ResultCallback<Void>) -> Logger {
        self.debouncedFlush(callback)
        return self
    }
    
    private lazy var debouncedFlush: (@escaping ResultCallback<Void>) -> () = debounceWithCallback(time: FLUSH_DEBOUNCE_TIME) { callback in
        let _ = self.immediateFlush() { result in
            callback(result)
        }
    }
    
    private func immediateFlush(callback: @escaping ResultCallback<Void>) -> Logger {
        if (events.events.count == 0 && events.tracking.count == 0) {
            return self
        }
        
        let flushEvents = events
        events = Events()
        
        var json: String
        
        do {
            json = try jsonStringify(flushEvents)
        } catch {
            callback(.failure(error))
            return self
        }
        
        var headers: Headers = [:]
        
        headerBuilders.forEach { builder in
            headers.merge(builder()) { (first, second) in
                second
            }
        }
        
        request(
            url: url,
            method: Method.POST,
            body: json,
            headers: headers
        ) { result in
            switch result {
                case .success:
                    callback(.success(()))
                case .failure(let error):
                    callback(.failure(error))
            }
        }
        
        return self
    }
    
    private func setupFlushInterval() {
        Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { _ in
            self.flush()
        }
    }
    
    public func addHeaderBuilder(headerBuilder : @escaping () -> Headers) -> Logger {
        headerBuilders.append(headerBuilder)
        return self
    }
    
    public func addPayloadBuilder(payloadBuilder : @escaping () -> Payload) -> Logger {
        payloadBuilders.append(payloadBuilder)
        return self
    }
    
    public func addTrackingBuilder(trackingBuilder : @escaping () -> Payload) -> Logger {
        trackingBuilders.append(trackingBuilder)
        return self
    }
}
