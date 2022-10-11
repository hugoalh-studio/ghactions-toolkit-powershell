import { argumentHandle, errorHandle } from "../handle.js";
import { create as ghactionsArtifact } from "@actions/artifact";
const {
	delimiter,
	Destination
} = argumentHandle();
const result = await ghactionsArtifact().downloadAllArtifacts(Destination).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify(result.map((value) => {
	return {
		Name: value.artifactName,
		Path: value.downloadPath
	};
})));
