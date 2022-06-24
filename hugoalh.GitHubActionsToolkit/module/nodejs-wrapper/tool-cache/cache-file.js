#!/usr/bin/env node
import { cacheFile as ghactionsToolCacheCacheFile } from "@actions/tool-cache";
const input = JSON.parse(process.argv[2]);
const result = await ghactionsToolCacheCacheFile(input.SourceFile, input.TargetFile, input.ToolName, input.Version, input.Architecture).catch((reason) => {
	console.error(reason);
	return process.exit(1);
});
console.log(process.argv[3]);
console.log(JSON.stringify({
	Path: result
}));
process.exit(0);
