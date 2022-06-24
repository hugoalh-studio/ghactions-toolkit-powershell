#!/usr/bin/env node
import { extractTar as ghactionToolCacheExtractTar } from "@actions/tool-cache";
const input = JSON.parse(process.argv[2]);
const result = await ghactionToolCacheExtractTar(input.File, input.Destination, input.Flag).catch((reason) => {
	console.error(reason);
	return process.exit(1);
});
console.log(process.argv[3]);
console.log(JSON.stringify({
	Path: result
}));
process.exit(0);
