//
//  util.swift
//  Test
//
//  Created by Daniel Brain on 10/11/20.
//

import Foundation

typealias EmptyCallback = () -> ()
typealias ResultCallback<T> = (Result<T, Error>) -> ()
typealias HandlerWithResultCallback<T> = (@escaping ResultCallback<T>) -> ()

func noopEmptyCallback() {}
func noopResultCallback<T>(_: Result<T, Error>) {}

func debounceWithCallback<T>(time : Double, handler: @escaping HandlerWithResultCallback<T>) -> HandlerWithResultCallback<T> {
    var callbacks: [ResultCallback<T>] = []
    var timer: Timer?
    
    return { callback in
        callbacks.append(callback)
        
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { _ in
            handler() { result in
                callbacks.forEach { innerCallback in
                    innerCallback(result)
                }
            }
        }
    }
}

enum Method: String {
    case GET, POST
}

let CONTENT_TYPE = "Content-Type"
let DEFAULT_CONTENT_TYPE = "application/json"
let DEFAULT_HEADERS: Headers = [:]

enum RequestError: Error {
    case NoResponse
}

func request(
    url: URL,
    method: Method,
    body: String,
    headers: Headers = DEFAULT_HEADERS,
    callback: @escaping ResultCallback<URLResponse>
) {
    var requestHeaders = headers
    if (requestHeaders[CONTENT_TYPE] == nil) {
        requestHeaders[CONTENT_TYPE] = DEFAULT_CONTENT_TYPE
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = body.data(using: String.Encoding.utf8)
    
    requestHeaders.forEach { (key, value) in
        request.setValue(value, forHTTPHeaderField: key)
    }
    
    print(requestHeaders)
    print(body)

    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
        if let response = response as? HTTPURLResponse {
            callback(.success(response))
        } else if let error = error {
            callback(.failure(error))
        } else {
            callback(.failure(RequestError.NoResponse))
        }
    }

    task.resume()
}

let jsonEncoder = JSONEncoder()

func jsonStringify<T: Encodable>(_ item : T) throws -> String {
    let data = try jsonEncoder.encode(item)
    let json = String(data: data, encoding: .utf8)!
    return json
}
