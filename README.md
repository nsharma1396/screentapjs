# ScreenTap.js

ScreenTap.js is a Node.js addon library that allows you to detect mouse/tap events on the screen/display. It currently supports both macOS and Windows. The library triggers events that may occur on different screens and provides the displayId of the currently active screen (screen where the event occured), such as mouse up/down events and foreground window changes/moves (currently only supported on Windows).

## Installation

You can install ScreenTap.js using npm:

```bash
npm install screentap
```

## API Usage

ScreenTap.js exports a `ScreenTap` class that extends `EventEmitter`. You can use it to listen for screen change events.

Here's a basic example:

```javascript
import ScreenTap from "screentap";

const screenTap = new ScreenTap();

screenTap.on("foregroundWindowUpdated", ({ eventName, displayId }) => {
	console.log("Foreground window updated ", displayId);
});
screenTap.on("leftMouseDown", ({ eventName, displayId }) => {
	console.log("Left mouse button down", displayId);
});
screenTap.on("leftMouseUp", ({ eventName, displayId }) => {
	console.log("Left mouse button up", displayId);
});
screenTap.on("rightMouseDown", ({ eventName, displayId }) => {
	console.log("Right mouse button down", displayId);
});
screenTap.on("rightMouseUp", ({ eventName, displayId }) => {
	console.log("Right mouse button up", displayId);
});

screenTap.startScreenTapListener();

setTimeout(() => {
	screenTap.stopScreenTapListener();
}, 10_000);
```

### API Reference

#### `startScreenTapListener()`

Starts the screen tap listener. This should be called to start receiving the events in your subscribed listeners.

#### `on(event: TScreenChangeEvent, listener: (event: IScreenTapEventResult) => void): this`

Subscribes to a screen change event. The `listener` callback is called with an `IScreenTapEventResult` object whenever the event occurs.

#### `off(event: TScreenChangeEvent, listener: (event: IScreenTapEventResult) => void): this`

Unsubscribes from a screen change event. The `listener` callback will no longer be called for the event.

#### `stopScreenTapListener()`

Stops the screen tap listener. This should be called when you no longer want to receive events.

### `IScreenTapEventResult`

This interface represents the object that is passed to event listeners when a screen change event occurs.

#### `eventName: TScreenChangeEvent`

This property is a string that indicates the type of the event that occurred. It can have one of the following values:

- `leftMouseDown`: Triggered when the left mouse button is pressed down.
- `leftMouseUp`: Triggered when the left mouse button is released.
- `rightMouseDown`: Triggered when the right mouse button is pressed down.
- `rightMouseUp`: Triggered when the right mouse button is released.
- `foregroundWindowUpdated` **(Windows only)**: Triggered when the foreground window is updated. This event is currently only supported on Windows.

#### `displayId: number`

The display where the event occurred. If the display cannot be determined, the `displayId` will be -1.

### EventEmitter API

Since `ScreenTap` extends `EventEmitter`, all the APIs of Node.js's `EventEmitter` are available. This includes methods like `addListener`, `removeListener`, `removeAllListeners`, `once`, and so on.

Here's an example of using the `once` method to listen for a single `leftMouseDown` event:

```javascript
import ScreenTap from "screentap";

const screenTap = new ScreenTap();

screenTap.once("leftMouseDown", (event) => {
	console.log("Left mouse button pressed", event);
});

screenTap.startScreenTapListener();
```

In this example, the listener is automatically removed after it is called once, so it will only log the first `leftMouseDown` event.

For more information about the `EventEmitter` API, see the [Node.js documentation](https://nodejs.org/api/events.html).

## Contributing

Contributions are welcome! Please submit a pull request or create an issue to propose changes or report bugs.

## License

ScreenTap.js is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
