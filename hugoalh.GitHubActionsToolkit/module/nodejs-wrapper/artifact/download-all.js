#!/usr/bin/env node
import { create as ghactionsArtifact } from "@actions/artifact";
const input = JSON.parse(process.argv[2]);
const result = await ghactionsArtifact().downloadAllArtifacts(input.Destination).catch((reason) => {
	console.error(reason);
	return process.exit(1);
});
console.log(process.argv[3]);
let outputObject = [];
for (let item of result) {
	outputObject.push({
		Name: item.artifactName,
		Path: item.downloadPath
	});
};
console.log(JSON.stringify(outputObject));
process.exit(0);
