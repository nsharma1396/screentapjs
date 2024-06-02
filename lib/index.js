"use strict";
const addon = require("./lib-binding.js");
const { EventEmitter } = require("events");

class ScreenTap extends EventEmitter {
	constructor() {
		super();
	}

	startScreenChangeListener() {
		this.stopScreenChangeListener();
		addon.start(this.emit.bind(this));
	}

	stopScreenChangeListener() {
		addon.stop();
	}
}

module.exports = ScreenTap;
