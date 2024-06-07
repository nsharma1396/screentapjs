import type { EventEmitter } from "events";

type TScreenChangeEvent =
	| "leftMouseDown"
	| "leftMouseUp"
	| "rightMouseDown"
	| "rightMouseUp"
	/**
	 * @description This event is emitted when the foreground window is updated. (Windows only)
	 */
	| "foregroundWindowUpdated";

type TScreenTapListener = (event: IScreenTapEventResult) => void;

export interface IScreenTapEventResult {
	eventName: TScreenChangeEvent;
	displayId: number;
}

declare class ScreenTap extends EventEmitter {
	startScreenTapListener: () => void;
	on: (event: TScreenChangeEvent, listener: TScreenTapListener) => this;
	off: (event: TScreenChangeEvent, listener: TScreenTapListener) => this;
	once: (event: TScreenChangeEvent, listener: TScreenTapListener) => this;
	addListener<K>(
		eventName: TScreenChangeEvent,
		listener: TScreenTapListener
	): this;
	removeListener<K>(
		eventName: TScreenChangeEvent,
		listener: TScreenTapListener
	): this;
	stopScreenTapListener: () => void;
}

export default ScreenTap;
