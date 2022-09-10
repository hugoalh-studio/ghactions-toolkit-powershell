#!/usr/bin/env node
import { create as ghactionsArtifact } from "@actions/artifact";
const input = JSON.parse(process.argv[2]);
const result = await ghactionsArtifact().downloadArtifact(input.Name, input.Destination, { createArtifactFolder: input.CreateSubfolder })
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(process.argv[3]);
console.log(JSON.stringify({
	Name: result.artifactName,
	Path: result.downloadPath
}));
process.exit(0);
