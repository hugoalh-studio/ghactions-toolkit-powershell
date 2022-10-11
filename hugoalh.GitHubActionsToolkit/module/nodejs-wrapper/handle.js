function argumentHandle() {
	const [inputs, delimiter] = process.argv.slice(2);
	return {
		...JSON.parse(inputs),
		delimiter
	};
}
function errorHandle(reason) {
	console.error(reason);
	return process.exit(1);
}
export {
	argumentHandle,
	errorHandle
};
