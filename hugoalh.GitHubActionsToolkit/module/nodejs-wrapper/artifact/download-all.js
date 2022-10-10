import { create as ghactionsArtifact } from "@actions/artifact";
const [inputs, delimiter] = process.argv.slice(2);
const { Destination } = JSON.parse(inputs);
const result = await ghactionsArtifact().downloadAllArtifacts(Destination)
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
console.log(delimiter);
console.log(JSON.stringify(result.map((value) => {
	return {
		Name: value.artifactName,
		Path: value.downloadPath
	};
})));
