import { argumentHandle, errorHandle } from "../handle.js";
import { create as ghactionsArtifact } from "@actions/artifact";
const {
	delimiter,
	BaseRoot,
	ContinueOnIssue,
	Name,
	Path,
	RetentionTime
} = argumentHandle();
const result = await ghactionsArtifact().uploadArtifact(Name, Path, BaseRoot, {
	continueOnError: ContinueOnIssue,
	retentionDays: RetentionTime
}).catch(errorHandle);
console.log(delimiter);
console.log(JSON.stringify({
	FailedItem: result.failedItems,
	FailedItems: result.failedItems,
	Item: result.artifactItems,
	Items: result.artifactItems,
	Name: result.artifactName,
	Size: result.size,
	Sizes: result.size
}));
