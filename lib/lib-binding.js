const binary = require("@mapbox/node-pre-gyp");
const path = require("path");
const fs = require("fs");

const bindingPath = binary.find(
	path.resolve(path.join(__dirname, "../package.json"))
);

const binding =
	fs.existsSync(bindingPath) && process.platform === "win32"
		? require(bindingPath)
		: {
				start: () => {
					throw new Error(
						"The module screentapjs was not found. Please try reinstalling the package."
					);
				},
				stop: () => {
					throw new Error(
						"The module screentapjs was not found. Please try reinstalling the package."
					);
				},
		  };

module.exports = binding;
