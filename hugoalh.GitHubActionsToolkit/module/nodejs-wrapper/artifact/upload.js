#!/usr/bin/env node
import { create as ghactionsArtifact } from "@actions/artifact";
const input = JSON.parse(process.argv[2]);
const result = await ghactionsArtifact().uploadArtifact(input.Name, input.Path, input.BaseRoot, {
	continueOnError: input.IgnoreIssuePaths,
	retentionDays: input.RetentionTime
}).catch((reason) => {
	console.error(reason);
	return process.exit(1);
});
console.log(process.argv[3]);
console.log(JSON.stringify({
	Name: result.artifactName,
	Item: result.artifactItems,
	Items: result.artifactItems,
	Size: result.size,
	Sizes: result.size,
	FailedItem: result.failedItems,
	FailedItems: result.failedItems
}));
process.exit(0);
