beaver-logger
------------

IOS implementation of https://github.com/krakenjs/beaver-logger

- Buffer your front-end logs and periodically send them to the server side
- Automatically flush logs for any errors or warnings

This is a great tool to use if you want to do logging on the client side in the same way you do on the server, without worrying about sending off a million beacons. You can quickly get an idea of what's going on on your client, including error cases, page transitions, or anything else you care to log!

Overview
---------

## Initialization

```swift
let logger = Logger(
    url: "https://foobar.com/my/logger/url"
);
```

## Basic logging

### `logger.info(<event>, <payload>);`

Queues a log. Options are `debug`, `info`, `warn`, `error`.

For example:

`logger.error(name: "something_went_wrong", payload: [ "error": "Some error stack" ])`

### `logger.track(<payload>);`

Call this to attach general tracking information to the current page. This is useful if the data is not associated with a specific event, and will be sent to the server the next time the logs are flushed.

For example:

`logger.track(payload: [ "sessionid": "1234" ])`

## Advanced

### `logger.addPayloadBuilder(<function>);`

Attach a method which is called and will attach values to **each individual log's payload** whenever the logs are flushed

```swift
logger.addPayloadBuilder {
    ["timestamp": getTimestamp()]
}
```

### `logger.addTrackingBuilder(<function>);`

Attach a method which is called and will attach values to **each individual log's tracking** whenever the logs are flushed

```swift
logger.addTrackingBuilder {
    ["session_id": getSessionID()]
}
```

### `logger.addHeaderBuilder(<function>);`

Attach a method which is called and will attach values to **each individual log requests' headers** whenever the logs are flushed

```swift
logger.addHeaderBuilder {
    ["x-csrf": getCSRFToken()]
}
```

### `logger.flush(<callback>);`

Flushes the logs to the server side. Recommended you don't call this manually, as it will happen automatically after a configured interval.

```swift
logger.flush {
    print("flush complete!")
}
```

## Chaining

```swift
logger
    .info("something_happened")
    .track(["session_id": "1234"])
    .flush()
```


Installing
----------

TBD


Configuration
-------------

Full configuration options:

```swift
let logger = Logger(

    // Url to send logs to
    url: "https://foobar.com/my/logger/url",

    // Prefix to prepend to all events
    prefix: "myapp",

    // Log level to display in the browser console
    logLevel: .warn,

    // Interval to flush logs to server, in seconds
    flushInterval: 60
)
```

Server Side
-----------

See https://github.com/krakenjs/beaver-logger
