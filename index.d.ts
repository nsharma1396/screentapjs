type TScreenChangeEvent =
	| "leftMouseDown"
	| "leftMouseUp"
	| "rightMouseDown"
	| "rightMouseUp"
	| "foregroundWindowUpdated";

declare class ScreenTap {
	startScreenChangeListener: () => void;
	on: (
		event: TScreenChangeEvent,
		listener: (monitorId: number) => void
	) => void;
	stopScreenChangeListener: () => void;
}

export = ScreenTap;
