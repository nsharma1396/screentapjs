"use strict";
const addon = require("./lib-binding.js");
const { EventEmitter } = require("events");

class ScreenTap extends EventEmitter {
	constructor() {
		super();
	}

	startScreenTapListener() {
		this.stopScreenTapListener();
		addon.start(this.emit.bind(this));
	}

	stopScreenTapListener() {
		addon.stop();
	}
}

module.exports = ScreenTap;
