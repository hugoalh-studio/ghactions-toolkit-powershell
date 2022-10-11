import { argumentHandle, errorHandle } from "../handle.js";
import { create as ghactionsArtifact } from "@actions/artifact";
const {
	delimiter,
	CreateSubfolder,
	Destination,
	Name
} = argumentHandle();
const result = await ghactionsArtifact().downloadArtifact(Name, Destination, { createArtifactFolder: CreateSubfolder }).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({
	Name: result.artifactName,
	Path: result.downloadPath
}));
