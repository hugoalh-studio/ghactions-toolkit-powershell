import { create as ghactionsArtifact } from "@actions/artifact";
const [inputs, delimiter] = process.argv.slice(2);
const {
	BaseRoot,
	ContinueOnIssue,
	Name,
	Path,
	RetentionTime
} = JSON.parse(inputs);
const result = await ghactionsArtifact().uploadArtifact(Name, Path, BaseRoot, {
	continueOnError: ContinueOnIssue,
	retentionDays: RetentionTime
})
	.catch((reason) => {
		console.error(reason);
		return process.exit(1);
	});
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
