#!/usr/bin/env node
import { downloadTool as ghactionToolCacheDownloadTool } from "@actions/tool-cache";
const input = JSON.parse(process.argv[2]);
const result = await ghactionToolCacheDownloadTool(input.Uri, input.Destination, input.Authorization, input.Header)
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(process.argv[3]);
console.log(JSON.stringify({ Path: result }));
process.exit(0);
