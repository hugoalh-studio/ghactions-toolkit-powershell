#!/usr/bin/env node
import { find as ghactionsToolCacheFind } from "@actions/tool-cache";
const input = JSON.parse(process.argv[2]);
const result = ghactionsToolCacheFind(input.ToolName, input.Version, input.Architecture);
console.log(process.argv[3]);
console.log(JSON.stringify({
	Path: result
}));
process.exit(0);
