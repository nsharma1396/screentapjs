const Screentapjs = require("../dist/binding.js");
const assert = require("assert");

assert(Screentapjs, "The expected function is undefined");

function testStartCall() {
	const result = Screentapjs.start();
	assert.strictEqual(result, true, "Unexpected value returned");
}

function testStopCall() {
	const result = Screentapjs.stop();
	assert.strictEqual(result, true, "Unexpected value returned");
}

assert.doesNotThrow(testStartCall, undefined, "testStart threw an expection");
assert.doesNotThrow(testStopCall, undefined, "testStop threw an expection");

console.log("Tests passed- everything looks OK!");
