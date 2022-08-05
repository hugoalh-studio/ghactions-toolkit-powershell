#!/usr/bin/env node
import { extractZip as ghactionToolCacheExtractZip } from "@actions/tool-cache";
const input = JSON.parse(process.argv[2]);
const result = await ghactionToolCacheExtractZip(input.File, input.Destination).catch((reason) => {
	console.error(reason);
	return process.exit(1);
});
console.log(process.argv[3]);
console.log(JSON.stringify({ Path: result }));
process.exit(0);
