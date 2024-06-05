const binary = require("@mapbox/node-pre-gyp");
const path = require("path");
const fs = require("fs");

const bindingPath = binary.find(
	path.resolve(path.join(__dirname, "../package.json"))
);

const binding =
	fs.existsSync(bindingPath) && ["win32", "darwin"].includes(process.platform)
		? require(bindingPath)
		: {
				start: () => {
					console.log(
						`WARNING: Screentap does not support ${process.platform} platform yet`
					);
				},
				stop: () => {
					console.log(
						`WARNING: Screentap does not support ${process.platform} platform yet`
					);
				},
		  };

module.exports = binding;
