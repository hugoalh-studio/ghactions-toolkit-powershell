import { DefaultArtifactClient as GitHubActionsArtifactClient, type ListArtifactsResponse as GitHubActionsArtifactListResponse, type DownloadArtifactResponse as GitHubActionsArtifactDownloadResponse, type UploadArtifactResponse as GitHubActionsArtifactUploadResponse, type GetArtifactResponse as GitHubActionsArtifactGetResponse } from "@actions/artifact";
import { restoreCache as ghactionsCacheRestoreCache, saveCache as ghactionsCacheSaveCache } from "@actions/cache";
import { getIDToken as ghactionsGetOpenIDConnectToken } from "@actions/core";
import { cacheDir as ghactionsToolCacheCacheDirectory, cacheFile as ghactionsToolCacheCacheFile, downloadTool as ghactionsToolCacheDownloadTool, extract7z as ghactionsToolCacheExtract7z, extractTar as ghactionsToolCacheExtractTar, extractXar as ghactionsToolCacheExtractXar, extractZip as ghactionsToolCacheExtractZip, find as ghactionsToolCacheFind, findAllVersions as ghactionsToolCacheFindAllVersions } from "@actions/tool-cache";
interface WrapperDataExchangeInput {
	name: string;
	parameters: { [key: string]: any; };
	token: string;
}
function convertEncoding(value: string, from: BufferEncoding, to: BufferEncoding): string {
	return Buffer.from(value, from).toString(to);
}
const { name, parameters, token }: WrapperDataExchangeInput = JSON.parse(convertEncoding(process.argv[2], "base64", "utf-8")) as WrapperDataExchangeInput;
function resolveFail(reason: string | Error): void {
	const output: Record<string, unknown> = {
		isSuccess: false
	};
	if (typeof reason === "string") {
		output.reason = reason;
	} else {
		let message = `${reason.name}: ${reason.message}`;
		if (typeof reason.stack !== "undefined") {
			message += `\n${reason.stack}`;
		}
		output.reason = message;
	}
	console.log(JSON.stringify(output));
}
function resolveSuccess(result: unknown): void {
	console.log(JSON.stringify({
		isSuccess: true,
		result
	}));
}
switch (name) {
	case "artifact/download":
		try {
			const result: GitHubActionsArtifactDownloadResponse = await new GitHubActionsArtifactClient().downloadArtifact(parameters.id, {
				findBy: parameters.findBy,
				path: parameters.path
			});
			resolveSuccess({
				path: result.downloadPath
			});
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "artifact/get":
		try {
			const result: GitHubActionsArtifactGetResponse = await new GitHubActionsArtifactClient().getArtifact(parameters.name, { findBy: parameters.findBy });
			resolveSuccess(result.artifact);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "artifact/list":
		try {
			const result: GitHubActionsArtifactListResponse = await new GitHubActionsArtifactClient().listArtifacts({
				findBy: parameters.findBy,
				latest: parameters.latest
			});
			resolveSuccess(result.artifacts);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "artifact/upload":
		try {
			const result: GitHubActionsArtifactUploadResponse = await new GitHubActionsArtifactClient().uploadArtifact(parameters.name, parameters.items, parameters.rootDirectory, {
				compressionLevel: parameters.compressionLevel,
				retentionDays: parameters.retentionDays
			});
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "cache/restore":
		try {
			const result: string | undefined = await ghactionsCacheRestoreCache(parameters.paths, parameters.primaryKey, parameters.restoreKeys, {
				concurrentBlobDownloads: parameters.concurrencyBlobDownload,
				downloadConcurrency: parameters.downloadConcurrency,
				lookupOnly: parameters.lookup,
				segmentTimeoutInMs: parameters.segmentTimeout,
				timeoutInMs: parameters.timeout,
				useAzureSdk: parameters.useAzureSdk
			});
			resolveSuccess(result ?? null);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "cache/save":
		try {
			const result: number = await ghactionsCacheSaveCache(parameters.paths, parameters.key, {
				uploadChunkSize: parameters.uploadChunkSize,
				uploadConcurrency: parameters.uploadConcurrency
			});
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "open-id-connect/get-token":
		try {
			const result: string = await ghactionsGetOpenIDConnectToken(parameters.audience);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/cache-directory":
		try {
			const result: string = await ghactionsToolCacheCacheDirectory(parameters.source, parameters.name, parameters.version, parameters.architecture);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/cache-file":
		try {
			const result: string = await ghactionsToolCacheCacheFile(parameters.source, parameters.target, parameters.name, parameters.version, parameters.architecture);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/download-tool":
		try {
			const result: string = await ghactionsToolCacheDownloadTool(parameters.url, parameters.destination, parameters.authorization, parameters.headers);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/extract-7z":
		try {
			const result: string = await ghactionsToolCacheExtract7z(parameters.file, parameters.destination, parameters["7zrPath"]);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/extract-tar":
		try {
			const result: string = await ghactionsToolCacheExtractTar(parameters.file, parameters.destination, parameters.flags);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/extract-xar":
		try {
			const result: string = await ghactionsToolCacheExtractXar(parameters.file, parameters.destination, parameters.flags);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/extract-zip":
		try {
			const result: string = await ghactionsToolCacheExtractZip(parameters.file, parameters.destination);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/find":
		try {
			const result: string = ghactionsToolCacheFind(parameters.name, parameters.version, parameters.architecture);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	case "tool-cache/find-all-versions":
		try {
			const result: string[] = ghactionsToolCacheFindAllVersions(parameters.name, parameters.architecture);
			resolveSuccess(result);
		} catch (error) {
			resolveFail(error);
		}
		break;
	default:
		resolveFail(`\`${name}\` is not a valid NodeJS wrapper name! Most likely a mistake made by the contributors, please report this issue.`);
		break;
}
