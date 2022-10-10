import { create as ghactionsArtifact } from "@actions/artifact";
const [inputs, delimiter] = process.argv.slice(2);
const {
	CreateSubfolder,
	Destination,
	Name
} = JSON.parse(inputs);
const result = await ghactionsArtifact().downloadArtifact(Name, Destination, { createArtifactFolder: CreateSubfolder })
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(delimiter);
console.log(JSON.stringify({
	Name: result.artifactName,
	Path: result.downloadPath
}));
