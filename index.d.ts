type TScreenChangeEvent =
	| "leftMouseDown"
	| "leftMouseUp"
	| "rightMouseDown"
	| "rightMouseUp"
	| "foregroundWindowUpdated";

declare class ScreenTap {
	startScreenTapListener: () => void;
	on: (
		event: TScreenChangeEvent,
		listener: (displayId: number) => void
	) => void;
	stopScreenTapListener: () => void;
}

export = ScreenTap;
