import { cacheDir as ghactionsToolCacheCacheDirectory, cacheFile as ghactionsToolCacheCacheFile, downloadTool as ghactionToolCacheDownloadTool, extract7z as ghactionToolCacheExtract7z, extractTar as ghactionToolCacheExtractTar, extractXar as ghactionToolCacheExtractXar, extractZip as ghactionToolCacheExtractZip, find as ghactionsToolCacheFind, findAllVersions as ghactionsToolCacheFindAllVersions } from "@actions/tool-cache";
import { create as ghactionsArtifact } from "@actions/artifact";
import { debug as ghactionsDebug, getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
import { restoreCache as ghactionsCacheRestoreCache, saveCache as ghactionsCacheSaveCache } from "@actions/cache";
function base64FromUTF8(item) {
	return Buffer.from(item, "utf8").toString("base64");
}
function base64ToUTF8(item) {
	return Buffer.from(item, "base64").toString("utf8");
}
function errorHandle(reason) {
	let message;
	if (typeof reason.message === "undefined") {
		message = reason;
	} else {
		message = reason.message;
		if (typeof reason.stack === "undefined") {
			message = `\n${reason.stack}`
		}
	}
	console.error(message);
	return process.exit(1);
}
function resultHandle(result) {
	return base64FromUTF8(JSON.stringify(result));
}
let [wrapperName, inputsRaw, delimiter] = process.argv.slice(2);
[wrapperName, inputsRaw, delimiter] = [wrapperName, inputsRaw, delimiter].map((value) => {
	return base64ToUTF8(value);
});
const inputs = JSON.parse(inputsRaw);
switch (wrapperName) {
	case "__debug":
		{
			ghactionsDebug(inputs.Message);
			console.log(delimiter);
			console.log(resultHandle({
				Message: "Hello, world!",
				Message2: "Good day, world!"
			}));
		}
		break;
	case "artifact/download":
		{
			const result = await ghactionsArtifact().downloadArtifact(inputs.Name, inputs.Destination, { createArtifactFolder: inputs.CreateSubfolder }).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({
				Name: result.artifactName,
				Path: result.downloadPath
			}));
		}
		break;
	case "artifact/download-all":
		{
			const result = await ghactionsArtifact().downloadAllArtifacts(inputs.Destination).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle(result.map((value) => {
				return {
					Name: value.artifactName,
					Path: value.downloadPath
				};
			})));
		}
		break;
	case "artifact/upload":
		{
			const result = await ghactionsArtifact().uploadArtifact(inputs.Name, inputs.Path, inputs.BaseRoot, {
				continueOnError: inputs.ContinueOnIssue,
				retentionDays: inputs.RetentionTime
			}).catch(errorHandle);
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
			const result = await ghactionsCacheRestoreCache(inputs.Path, inputs.PrimaryKey, inputs.RestoreKey, {
				downloadConcurrency: inputs.DownloadConcurrency,
				lookupOnly: inputs.LookUp,
				segmentTimeoutInMs: inputs.SegmentTimeout,
				timeoutInMs: inputs.Timeout,
				useAzureSdk: inputs.UseAzureSdk
			}).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ CacheKey: result ?? null }));
		}
		break;
	case "cache/save":
		{
			const result = await ghactionsCacheSaveCache(inputs.Path, inputs.Key, {
				uploadChunkSize: inputs.UploadChunkSizes,
				uploadConcurrency: inputs.UploadConcurrency
			}).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ CacheId: result }));
		}
		break;
	case "open-id-connect/get-token":
		{
			const result = await ghactionsGetOpenIDConnectToken(inputs.Audience).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ Token: result }));
		}
		break;
	case "tool-cache/cache-directory":
		{
			const result = await ghactionsToolCacheCacheDirectory(inputs.Source, inputs.Name, inputs.Version, inputs.Architecture).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ Path: result }));
		}
		break;
	case "tool-cache/cache-file":
		{
			const result = await ghactionsToolCacheCacheFile(inputs.Source, inputs.Target, inputs.Name, inputs.Version, inputs.Architecture).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ Path: result }));
		}
		break;
	case "tool-cache/download-tool":
		{
			const result = await ghactionToolCacheDownloadTool(inputs.Uri, inputs.Destination, inputs.Authorization, inputs.Header).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ Path: result }));
		}
		break;
	case "tool-cache/extract-7z":
		{
			const result = await ghactionToolCacheExtract7z(inputs.File, inputs.Destination, inputs["7zrPath"]).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ Path: result }));
		}
		break;
	case "tool-cache/extract-tar":
		{
			const result = await ghactionToolCacheExtractTar(inputs.File, inputs.Destination, inputs.Flag).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ Path: result }));
		}
		break;
	case "tool-cache/extract-xar":
		{
			const result = await ghactionToolCacheExtractXar(inputs.File, inputs.Destination, inputs.Flag).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ Path: result }));
		}
		break;
	case "tool-cache/extract-zip":
		{
			const result = await ghactionToolCacheExtractZip(inputs.File, inputs.Destination).catch(errorHandle);
			console.log(delimiter);
			console.log(resultHandle({ Path: result }));
		}
		break;
	case "tool-cache/find":
		{
			const result = ghactionsToolCacheFind(inputs.Name, inputs.Version, inputs.Architecture);
			console.log(delimiter);
			console.log(resultHandle({ Path: result }));
		}
		break;
	case "tool-cache/find-all-versions":
		{
			const result = ghactionsToolCacheFindAllVersions(inputs.Name, inputs.Architecture);
			console.log(delimiter);
			console.log(resultHandle({ Paths: result }));
		}
		break;
	default:
		errorHandle(`\`${wrapperName}\` is not a valid NodeJS wrapper name! Most likely a mistake made by the contributors, please report this issue.`);
		break;
}
