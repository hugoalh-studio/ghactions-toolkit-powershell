#!/usr/bin/env node
import { extract7z as ghactionToolCacheExtract7z } from "@actions/tool-cache";
const input = JSON.parse(process.argv[2]);
const result = await ghactionToolCacheExtract7z(input.File, input.Destination, input["7zrPath"]).catch((reason) => {
	console.error(reason);
	return process.exit(1);
});
console.log(process.argv[3]);
console.log(JSON.stringify({ Path: result }));
process.exit(0);
