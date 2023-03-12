import { cacheDir as ghactionsToolCacheCacheDirectory, cacheFile as ghactionsToolCacheCacheFile, downloadTool as ghactionToolCacheDownloadTool, extract7z as ghactionToolCacheExtract7z, extractTar as ghactionToolCacheExtractTar, extractXar as ghactionToolCacheExtractXar, extractZip as ghactionToolCacheExtractZip, find as ghactionsToolCacheFind, findAllVersions as ghactionsToolCacheFindAllVersions } from "@actions/tool-cache";
import { create as ghactionsArtifact } from "@actions/artifact";
import { getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
import { restoreCache as ghactionsCacheRestoreCache, saveCache as ghactionsCacheSaveCache } from "@actions/cache";
function errorHandle(reason) {
	console.error(reason?.message ?? reason);
	return process.exit(1);
}
const [wrapperName, inputsRaw, delimiter] = process.argv.slice(2);
const inputs = JSON.parse(inputsRaw);
switch (wrapperName) {
	case "artifact/download":
		{
			const result = await ghactionsArtifact().downloadArtifact(inputs.Name, inputs.Destination, { createArtifactFolder: inputs.CreateSubfolder }).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({
				Name: result.artifactName,
				Path: result.downloadPath
			}));
		}
		break;
	case "artifact/download-all":
		{
			const result = await ghactionsArtifact().downloadAllArtifacts(inputs.Destination).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify(result.map((value) => {
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
			console.log(JSON.stringify({
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
			console.log(JSON.stringify({ CacheKey: result ?? null }));
		}
		break;
	case "cache/save":
		{
			const result = await ghactionsCacheSaveCache(inputs.Path, inputs.Key, {
				uploadChunkSize: inputs.UploadChunkSizes,
				uploadConcurrency: inputs.UploadConcurrency
			}).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ CacheId: result }));
		}
		break;
	case "open-id-connect/get-token":
		{
			const result = await ghactionsGetOpenIDConnectToken(inputs.Audience).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ Token: result }));
		}
		break;
	case "tool-cache/cache-directory":
		{
			const result = await ghactionsToolCacheCacheDirectory(inputs.Source, inputs.Name, inputs.Version, inputs.Architecture).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ Path: result }));
		}
		break;
	case "tool-cache/cache-file":
		{
			const result = await ghactionsToolCacheCacheFile(inputs.Source, inputs.Target, inputs.Name, inputs.Version, inputs.Architecture).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ Path: result }));
		}
		break;
	case "tool-cache/download-tool":
		{
			const result = await ghactionToolCacheDownloadTool(inputs.Uri, inputs.Destination, inputs.Authorization, inputs.Header).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ Path: result }));
		}
		break;
	case "tool-cache/extract-7z":
		{
			const result = await ghactionToolCacheExtract7z(inputs.File, inputs.Destination, inputs["7zrPath"]).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ Path: result }));
		}
		break;
	case "tool-cache/extract-tar":
		{
			const result = await ghactionToolCacheExtractTar(inputs.File, inputs.Destination, inputs.Flag).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ Path: result }));
		}
		break;
	case "tool-cache/extract-xar":
		{
			const result = await ghactionToolCacheExtractXar(inputs.File, inputs.Destination, inputs.Flag).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ Path: result }));
		}
		break;
	case "tool-cache/extract-zip":
		{
			const result = await ghactionToolCacheExtractZip(inputs.File, inputs.Destination).catch(errorHandle);
			console.log(delimiter);
			console.log(JSON.stringify({ Path: result }));
		}
		break;
	case "tool-cache/find":
		{
			const result = ghactionsToolCacheFind(inputs.Name, inputs.Version, inputs.Architecture);
			console.log(delimiter);
			console.log(JSON.stringify({ Path: result }));
		}
		break;
	case "tool-cache/find-all-versions":
		{
			const result = ghactionsToolCacheFindAllVersions(inputs.Name, inputs.Architecture);
			console.log(delimiter);
			console.log(JSON.stringify({ Paths: result }));
		}
		break;
	default:
		errorHandle(`\`${wrapperName}\` is not a valid NodeJS wrapper name! Most likely a mistake made by the contributors, please report this issue.`);
		break;
}
