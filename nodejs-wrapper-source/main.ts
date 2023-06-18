import { create as ghactionsArtifact, type DownloadResponse as GitHubActionsArtifactDownloadResponse, type UploadResponse as GitHubActionsArtifactUploadResponse } from "@actions/artifact";
import { restoreCache as ghactionsCacheRestoreCache, saveCache as ghactionsCacheSaveCache } from "@actions/cache";
import { debug as ghactionsDebug, getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
import { cacheDir as ghactionsToolCacheCacheDirectory, cacheFile as ghactionsToolCacheCacheFile, downloadTool as ghactionsToolCacheDownloadTool, extract7z as ghactionsToolCacheExtract7z, extractTar as ghactionsToolCacheExtractTar, extractXar as ghactionsToolCacheExtractXar, extractZip as ghactionsToolCacheExtractZip, find as ghactionsToolCacheFind, findAllVersions as ghactionsToolCacheFindAllVersions } from "@actions/tool-cache";
function encodeConvert(item: string, from: BufferEncoding, to: BufferEncoding): string {
	return Buffer.from(item, from).toString(to);
}
function errorHandle(reason: any): void {
	let message: string;
	if (typeof reason.message === "undefined") {
		message = reason;
	} else {
		message = reason.message;
		if (typeof reason.stack === "undefined") {
			message = `\n${reason.stack}`;
		}
	}
	console.error(message);
	process.exit(1);
}
function resultHandle(result: object): string {
	return encodeConvert(JSON.stringify(result), "utf8", "base64");
}
try {
	let [wrapperName, inputsRaw, delimiter] = process.argv.slice(2).map((value: string): string => {
		return encodeConvert(value, "base64", "utf8");
	});
	let inputs = JSON.parse(inputsRaw);
	switch (wrapperName) {
		case "__debug":
			ghactionsDebug(inputs.Message);
			console.log(delimiter);
			console.log(resultHandle({
				Message: "Hello, world!",
				Message2: "Good day, world!"
			}));
			break;
		case "artifact/download":
			{
				let result: GitHubActionsArtifactDownloadResponse = await ghactionsArtifact().downloadArtifact(inputs.Name, inputs.Destination, { createArtifactFolder: inputs.CreateSubfolder });
				console.log(delimiter);
				console.log(resultHandle({
					Name: result.artifactName,
					Path: result.downloadPath
				}));
			}
			break;
		case "artifact/download-all":
			{
				let result: GitHubActionsArtifactDownloadResponse[] = await ghactionsArtifact().downloadAllArtifacts(inputs.Destination);
				console.log(delimiter);
				console.log(resultHandle(result.map((value: GitHubActionsArtifactDownloadResponse) => {
					return {
						Name: value.artifactName,
						Path: value.downloadPath
					};
				})));
			}
			break;
		case "artifact/upload":
			{
				let result: GitHubActionsArtifactUploadResponse = await ghactionsArtifact().uploadArtifact(inputs.Name, inputs.Path, inputs.BaseRoot, {
					continueOnError: inputs.ContinueOnIssue,
					retentionDays: inputs.RetentionTime
				});
				console.log(delimiter);
				console.log(resultHandle({
					FailedItem: result.failedItems,
					FailedItems: result.failedItems,
					Item: result.artifactItems,
					Items: result.artifactItems,
					Name: result.artifactName,
					Size: result.size,
					Sizes: result.size
				}));
			}
			break;
		case "cache/restore":
			{
				let result: string = await ghactionsCacheRestoreCache(inputs.Path, inputs.PrimaryKey, inputs.RestoreKey, {
					downloadConcurrency: inputs.DownloadConcurrency,
					lookupOnly: inputs.LookUp,
					segmentTimeoutInMs: inputs.SegmentTimeout,
					timeoutInMs: inputs.Timeout,
					useAzureSdk: inputs.UseAzureSdk
				});
				console.log(delimiter);
				console.log(resultHandle({ CacheKey: result ?? null }));
			}
			break;
		case "cache/save":
			{
				let result: number = await ghactionsCacheSaveCache(inputs.Path, inputs.Key, {
					uploadChunkSize: inputs.UploadChunkSizes,
					uploadConcurrency: inputs.UploadConcurrency
				});
				console.log(delimiter);
				console.log(resultHandle({ CacheId: result }));
			}
			break;
		case "open-id-connect/get-token":
			{
				let result: string = await ghactionsGetOpenIDConnectToken(inputs.Audience);
				console.log(delimiter);
				console.log(resultHandle({ Token: result }));
			}
			break;
		case "tool-cache/cache-directory":
			{
				let result: string = await ghactionsToolCacheCacheDirectory(inputs.Source, inputs.Name, inputs.Version, inputs.Architecture);
				console.log(delimiter);
				console.log(resultHandle({ Path: result }));
			}
			break;
		case "tool-cache/cache-file":
			{
				let result: string = await ghactionsToolCacheCacheFile(inputs.Source, inputs.Target, inputs.Name, inputs.Version, inputs.Architecture);
				console.log(delimiter);
				console.log(resultHandle({ Path: result }));
			}
			break;
		case "tool-cache/download-tool":
			{
				let result: string = await ghactionsToolCacheDownloadTool(inputs.Uri, inputs.Destination, inputs.Authorization, inputs.Header);
				console.log(delimiter);
				console.log(resultHandle({ Path: result }));
			}
			break;
		case "tool-cache/extract-7z":
			{
				let result: string = await ghactionsToolCacheExtract7z(inputs.File, inputs.Destination, inputs["7zrPath"]);
				console.log(delimiter);
				console.log(resultHandle({ Path: result }));
			}
			break;
		case "tool-cache/extract-tar":
			{
				let result: string = await ghactionsToolCacheExtractTar(inputs.File, inputs.Destination, inputs.Flag);
				console.log(delimiter);
				console.log(resultHandle({ Path: result }));
			}
			break;
		case "tool-cache/extract-xar":
			{
				let result: string = await ghactionsToolCacheExtractXar(inputs.File, inputs.Destination, inputs.Flag);
				console.log(delimiter);
				console.log(resultHandle({ Path: result }));
			}
			break;
		case "tool-cache/extract-zip":
			{
				let result: string = await ghactionsToolCacheExtractZip(inputs.File, inputs.Destination);
				console.log(delimiter);
				console.log(resultHandle({ Path: result }));
			}
			break;
		case "tool-cache/find":
			{
				let result: string = ghactionsToolCacheFind(inputs.Name, inputs.Version, inputs.Architecture);
				console.log(delimiter);
				console.log(resultHandle({ Path: result }));
			}
			break;
		case "tool-cache/find-all-versions":
			{
				let result: string[] = ghactionsToolCacheFindAllVersions(inputs.Name, inputs.Architecture);
				console.log(delimiter);
				console.log(resultHandle({ Paths: result }));
			}
			break;
		default:
			throw new Error(`\`${wrapperName}\` is not a valid NodeJS wrapper name! Most likely a mistake made by the contributors, please report this issue.`);
	}
} catch (error) {
	errorHandle(error);
}
